import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // MARK: - Current user id (user.id is already UUID in your SDK)
    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        return user.id   // <-- user.id is UUID (no string conversion)
    }

    // MARK: - READ
    func load() async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            let rows: [Child] = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", uid.uuidString)   // pass as String to PostgREST
                .order("created_at", ascending: true)
                .execute()
                .decoded()
            self.children = rows
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - CREATE
    func add(name: String, birthdate: Date?) async {
        struct NewChild: Encodable {
            let parent_user_id: String
            let name: String
            let birthdate: String?
        }
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            let iso = ISO8601DateFormatter()

            let payload = NewChild(
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { iso.string(from: $0) }
            )

            // Your package wants `value:` here
            try await client.database
                .from("children")
                .insert(value: payload)
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - UPDATE
    func update(child: Child) async {
        // send a DB-friendly payload (URL -> String, Date -> ISO string)
        struct UpdateChild: Encodable {
            let name: String
            let birthdate: String?
            let avatar_url: String?
        }
        do {
            isLoading = true; defer { isLoading = false }
            let iso = ISO8601DateFormatter()
            let payload = UpdateChild(
                name: child.name,
                birthdate: child.birthdate.map { iso.string(from: $0) },
                avatar_url: child.avatarURL?.absoluteString
            )

            try await client.database
                .from("children")
                .update(value: payload)                     // <-- `value:` label
                .eq("id", child.id.uuidString)
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - DELETE
    func delete(id: UUID) async {
        do {
            isLoading = true; defer { isLoading = false }
            try await client.database
                .from("children")
                .delete()
                .eq("id", id.uuidString)
                .execute()
            children.removeAll { $0.id == id }
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - AVATAR (requires public 'avatars' bucket)
    func uploadAvatar(for child: Child, imageData: Data) async {
        do {
            isLoading = true; defer { isLoading = false }
            let path = "child/\(child.id.uuidString).jpg"

            try await client.storage
                .from("avatars")
                .upload(path: path, file: imageData,
                        options: FileOptions(cacheControl: "3600", upsert: true))

            let url = try client.storage.from("avatars").getPublicURL(path: path)
            var updated = child
            updated.avatarURL = URL(string: url)
            await update(child: updated)
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
