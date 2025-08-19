import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // Read from Info.plist; fallback to "avatars"
    private var avatarsBucket: String {
        (Bundle.main.object(forInfoDictionaryKey: "AVATAR_BUCKET") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "avatars"
    }

    // Your SDK exposes user.id as UUID.
    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id
    }

    // --- Optional: call this once (e.g., before first upload) to confirm the bucket exists.
    // NOTE: supabase-swift uses an UNLABELED parameter for getBucket.
    private func assertBucketExists() async throws {
        _ = try await client.storage.getBucket(avatarsBucket) // ← no 'id:' label
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

            var avatarPath: String? = nil
            if let data = avatarData {
                // Verify bucket only when needed (avoids false failures when no photo)
                try await assertBucketExists()

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

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(payload)   // your SDK: no 'value:' label
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
                .update(payload)                    // your SDK: no 'value:' label
                .eq("id", value: child.id.uuidString)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - DELETE
    func delete(_ id: UUID) async {           // ← matches call site: delete(svc.children[i].id)
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

    // Build a public URL to display an avatar
    func publicURL(for path: String) -> URL? {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else { return nil }
        return URL(string: "\(base)/storage/v1/object/public/\(avatarsBucket)/\(path)")
    }
}
