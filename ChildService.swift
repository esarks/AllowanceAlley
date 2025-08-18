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
        // user.id is a UUID-compatible string in recent SDKs
        guard let id = UUID(uuidString: user.id) else {
            throw NSError(domain: "ChildService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid user id"])
        }
        return id
    }

    // MARK: Load
    func load() async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            let rows: [Child] = try await client.database
                .from("children")
                .select()
                .eq("parent_user_id", uid.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .decoded()
            self.children = rows
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: Create
    func add(name: String, birthdate: Date?) async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()

            struct NewChild: Encodable {
                let parent_user_id: String
                let name: String
                let birthdate: String?
            }

            let iso = ISO8601DateFormatter()
            let payload = NewChild(
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { iso.string(from: $0) }
            )

            // Insert (no 'values:' label in this SDK)
            try await client.database
                .from("children")
                .insert(payload)
                .execute()

            // Refresh
            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: Update
    func update(child: Child) async {
        do {
            isLoading = true; defer { isLoading = false }

            try await client.database
                .from("children")
                .update(child) // no 'values:' label
                .eq("id", child.id.uuidString)
                .execute()

            if let idx = children.firstIndex(where: { $0.id == child.id }) {
                children[idx] = child
            } else {
                await load()
            }
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: Delete
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

    // MARK: Avatar (optional; requires public 'avatars' bucket)
    func uploadAvatar(for child: Child, imageData: Data) async {
        do {
            isLoading = true; defer { isLoading = false }
            let path = "child/\(child.id.uuidString).jpg"

            try await client.storage
                .from("avatars")
                .upload(path: path, file: imageData,
                        options: FileOptions(cacheControl: "3600", upsert: true))

            let publicURL = try client.storage.from("avatars").getPublicURL(path: path)
            var updated = child
            updated.avatarURL = URL(string: publicURL)
            await update(child: updated)
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
