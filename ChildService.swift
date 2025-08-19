import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // Your SDK's user.id is already a UUID — return it directly.
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

            // Make generics explicit so .value is available (no .decoded on Void)
            let resp: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", value: uid.uuidString)   // <- String for PostgREST filter
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
            let created_at: String
        }

        do {
            let uid = try await currentUserId()
            let id = UUID()
            let iso = ISO8601DateFormatter()

            var avatarPath: String? = nil
            if let data = avatarData {
                let path = "avatars/\(id.uuidString).jpg"
                try await client.storage
                    .from("avatars") // make sure this bucket exists & is public
                    .upload(path: path, file: data,
                            options: FileOptions(contentType: "image/jpeg", upsert: true))
                avatarPath = path
            }

            let payload = NewChild(
                id: id,
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { iso.string(from: $0) },
                avatar_url: avatarPath,
                created_at: iso.string(from: Date())
            )

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(payload)      // no 'values:' label in some versions; if Xcode asks, use insert(value:)
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

        // Send a DB‑friendly payload (strings for date/url)
        struct UpdateChild: Encodable {
            let name: String
            let birthdate: String?
            let avatar_url: String?
        }

        do {
            let iso = ISO8601DateFormatter()
            let payload = UpdateChild(
                name: child.name,
                birthdate: child.birthdate.map { iso.string(from: $0) },
                avatar_url: child.avatarUrl
            )

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .update(payload)                           // if the SDK requires it, use update(value: payload)
                .eq("id", value: child.id.uuidString)     // <- use 'value:' label
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
                .eq("id", value: id.uuidString)   // <- use 'value:' label
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - Optional avatar upload to update an existing child
    func uploadAvatar(for child: Child, imageData: Data) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let path = "avatars/\(child.id.uuidString).jpg"
            try await client.storage
                .from("avatars")
                .upload(path: path, file: imageData,
                        options: FileOptions(contentType: "image/jpeg", upsert: true))

            var updated = child
            updated.avatarUrl = path
            await update(updated)
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
