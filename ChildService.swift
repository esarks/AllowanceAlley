import Foundation
import Supabase
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        guard let id = UUID(uuidString: user.id) else {
            throw NSError(domain: "ChildService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid user id"])
        }
        return id
    }

    // READ
    func load() async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            let rows: [Child] = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", uid.uuidString)    // <- String id
                .order("created_at", ascending: true)
                .execute()
                .decoded()
            self.children = rows
        } catch { self.errorMessage = (error as NSError).localizedDescription }
    }

    // CREATE
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
            try await client.database.from("children").insert(payload).execute()   // no label, no decode
            await load()
        } catch { self.errorMessage = (error as NSError).localizedDescription }
    }

    // UPDATE
    func update(child: Child) async {
        // convert to DB payload so URL encodes as String
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
                .update(payload)                                 // no 'values:' label
                .eq("id", child.id.uuidString)
                .execute()
            await load()
        } catch { self.errorMessage = (error as NSError).localizedDescription }
    }

    // DELETE
    func delete(id: UUID) async {
        do {
            isLoading = true; defer { isLoading = false }
            try await client.database.from("children").delete().eq("id", id.uuidString).execute()
            children.removeAll { $0.id == id }
        } catch { self.errorMessage = (error as NSError).localizedDescription }
    }

    // AVATAR (public 'avatars' bucket)
    func uploadAvatar(for child: Child, imageData: Data) async {
        do {
            isLoading = true; defer { isLoading = false }
            let path = "child/\(child.id.uuidString).jpg"
            try await client.storage.from("avatars")
                .upload(path: path, file: imageData, options: FileOptions(cacheControl: "3600", upsert: true))
            let url = try client.storage.from("avatars").getPublicURL(path: path)
            var updated = child
            updated.avatarURL = URL(string: url)
            await update(child: updated)
        } catch { self.errorMessage = (error as NSError).localizedDescription }
    }
}
