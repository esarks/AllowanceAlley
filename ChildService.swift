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

    // supabase-swift user.id is UUID
    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id
    }

    // Optional sanity check; parameter is UNLABELED in supabase-swift
    private func assertBucketExists() async throws {
        _ = try await client.storage.getBucket(avatarsBucket)
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

    // MARK: - CREATE (insert first, then try avatar upload/update)
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

            // 1) Insert the child without blocking on avatar
            let insertPayload = NewChild(
                id: id,
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { Child.dateOnly.string(from: $0) },
                avatar_url: nil
            )

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(insertPayload)
                .select()
                .execute()

            // 2) If we have an avatar, attempt upload, then update row
            if let data = avatarData {
                do {
                    try await assertBucketExists() // will throw if wrong name/project
                    let path = "child/\(id.uuidString).jpg" // no leading slash

                    try await client.storage
                        .from(avatarsBucket)
                        .upload(
                            path: path,
                            file: data,
                            options: FileOptions(contentType: "image/jpeg", upsert: true)
                        )

                    // Update the just-created child with avatar_url
                    struct UpdateChild: Encodable { let avatar_url: String? }
                    let _: PostgrestResponse<[Child]> = try await client.database
                        .from("children")
                        .update(UpdateChild(avatar_url: path))
                        .eq("id", value: id.uuidString)
                        .select()
                        .execute()
                } catch {
                    // Keep the child; just tell the user the photo failed
                    self.errorMessage = "Saved child, but photo upload failed: \((error as NSError).localizedDescription)"
                }
            }

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
    func delete(_ id: UUID) async {
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

    // Build a public URL for display
    func publicURL(for path: String) -> URL? {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else { return nil }
        return URL(string: "\(base)/storage/v1/object/public/\(avatarsBucket)/\(path)")
    }
}
