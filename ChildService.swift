import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client
    private let avatarsBucket = "avatars"

    // Your installed SDK exposes user.id as UUID – return it directly.
    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id
    }

    // MARK: - READ
    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await currentUserId()

            // Make the generic concrete so we can read .value directly.
            let resp: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", value: uid.uuidString) // PostgREST expects String
                .order("created_at", ascending: true)
                .execute()

            self.children = resp.value
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - CREATE
    func add(name: String, birthdate: Date?, avatarData: Data? = nil) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        struct NewChild: Encodable {
            let id: UUID
            let parent_user_id: String
            let name: String
            let birthdate: String?
            let avatar_url: String?
        }

        do {
            let uid = try await currentUserId()
            let id = UUID()

            // Optional avatar upload to a public bucket
            var avatarPath: String? = nil
            if let data = avatarData {
                let path = "child/\(id.uuidString).jpg"
                try await client.storage
                    .from(avatarsBucket)
                    .upload(
                        path: path,
                        file: data,
                        options: FileOptions(contentType: "image/jpeg", upsert: true)
                    )
                avatarPath = path
            }

            let payload = NewChild(
                id: id,
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { Child.dateOnly.string(from: $0) }, // "yyyy-MM-dd"
                avatar_url: avatarPath
            )

            // Insert row; select() returns the inserted row typed as [Child]
            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(value: payload)  // your SDK expects the 'value:' label
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - UPDATE
    func update(_ child: Child) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        struct UpdateChild: Encodable {
            let name: String
            let birthdate: String?
            let avatar_url: String?
        }

        do {
            let payload = UpdateChild(
                name: child.name,
                birthdate: child.birthdate.map { Child.dateOnly.string(from: $0) },
                avatar_url: child.avatarUrl
            )

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .update(value: payload) // 'value:' label required by your package
                .eq("id", value: child.id.uuidString)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - DELETE
    func delete(id: UUID) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let _: PostgrestResponse<Void> = try await client.database
                .from("children")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - Upload/replace avatar for an existing child
    func uploadAvatar(for child: Child, imageData: Data) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let path = "child/\(child.id.uuidString).jpg"
            try await client.storage
                .from(avatarsBucket)
                .upload(
                    path: path,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )

            var updated = child
            updated.avatarUrl = path
            await update(updated)
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
