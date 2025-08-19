import Foundation
import Supabase

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // Read the bucket name from Info.plist (key: AVATAR_BUCKET). Default to "avatars".
    private var avatarsBucket: String {
        (Bundle.main.object(forInfoDictionaryKey: "AVATAR_BUCKET") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "avatars"
    }

    // MARK: - Helpers

    /// Returns the current user id (UUID) or throws if not authenticated.
    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id
    }

    /// Optional: ensure the bucket exists (anon can read bucket metadata in most setups).
    /// If your anon key cannot read storage metadata, you can no-op this function.
    private func assertBucketExists() async throws {
        // FIX: correct signature is getBucket(_:)
        _ = try await client.storage.getBucket(avatarsBucket)
    }

    // MARK: - READ

    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await currentUserId()
            // Server will coerce UUID properly when sent as string
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

            // Ensure bucket exists (safe to keep; comment out if your anon key can’t access metadata)
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

            // Insert and return the inserted row as [Child]
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

    // MARK: - Public URL helper

    /// Builds a public URL for the stored image (works if the bucket is public).
    func publicURL(for path: String) -> URL? {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            return nil
        }
        return URL(string: "\(base)/storage/v1/object/public/\(avatarsBucket)/\(path)")
    }
}
