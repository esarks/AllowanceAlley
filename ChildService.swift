import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // Name of your Storage bucket (Info.plist key optional)
    private var avatarsBucket: String {
        (Bundle.main.object(forInfoDictionaryKey: "AVATAR_BUCKET") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "avatars"
    }

    // MARK: - Auth

    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id
    }

    // Throws if the bucket does not exist (anon key can read bucket metadata)
    private func assertBucketExists() async throws {
        _ = try await client.storage.getBucket(avatarsBucket) // no label
    }

    // MARK: - READ

    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await currentUserId()
            let resp: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", value: uid.uuidString)
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

            // Ensure bucket exists before upload
            try await assertBucketExists()

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
                birthdate: birthdate.map { Child.dateOnly.string(from: $0) },
                avatar_url: avatarPath
            )

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(payload)
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
                .update(payload)
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

    // MARK: - Avatar (replace / add on existing child)

    func uploadAvatar(for child: Child, imageData: Data) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await assertBucketExists()

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

    // MARK: - Public URL helper

    func publicURL(for path: String) -> URL? {
        guard
            let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        else { return nil }

        // Public object URL format:
        // {SUPABASE_URL}/storage/v1/object/public/{bucket}/{path}
        return URL(string: "\(base)/storage/v1/object/public/\(avatarsBucket)/\(path)")
    }
}
