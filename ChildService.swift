import Foundation
import Supabase
import PhotosUI
import UIKit

@MainActor
final class ChildService: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    private func currentUserId() async throws -> UUID {
        let user = try await client.auth.user()
        guard let id = UUID(uuidString: user.id.uuidString) ?? UUID(uuidString: user.id.description) ?? UUID(uuidString: user.id) else {
            throw NSError(domain: "ChildService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid user id"])
        }
        return id
    }

    // MARK: - CRUD

    func load() async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            // Fetch children for this parent
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

    func add(name: String, birthdate: Date?) async {
        do {
            isLoading = true; defer { isLoading = false }
            let uid = try await currentUserId()
            struct NewChild: Encodable {
                let parent_user_id: String
                let name: String
                let birthdate: String?
            }
            let payload = NewChild(
                parent_user_id: uid.uuidString,
                name: name,
                birthdate: birthdate.map { ISO8601DateFormatter().string(from: $0) }
            )

            // insert returning row
            let inserted: [Child] = try await client.database
                .from("children")
                .insert(values: payload, returning: .representation)
                .execute()
                .decoded()
            if let c = inserted.first { children.append(c) }
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    func update(child: Child) async {
        do {
            isLoading = true; defer { isLoading = false }
            let payload = child
            _ = try await client.database
                .from("children")
                .update(values: payload)
                .eq("id", child.id.uuidString)
                .execute()
            if let idx = children.firstIndex(where: { $0.id == child.id }) {
                children[idx] = child
            }
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    func delete(id: UUID) async {
        do {
            isLoading = true; defer { isLoading = false }
            _ = try await client.database
                .from("children")
                .delete()
                .eq("id", id.uuidString)
                .execute()
            children.removeAll { $0.id == id }
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - Avatar upload (optional but nice)

    func uploadAvatar(for child: Child, imageData: Data) async {
        do {
            isLoading = true; defer { isLoading = false }
            let path = "child/\(child.id.uuidString).jpg"
            // upsert into public 'avatars' bucket
            try await client.storage
                .from("avatars")
                .upload(
                    path: path,
                    file: imageData,
                    options: FileOptions(cacheControl: "3600", upsert: true)
                )
            // public URL (bucket must be public in Supabase UI)
            let url = try client.storage.from("avatars").getPublicURL(path: path)
            var updated = child
            updated.avatarURL = URL(string: url)
            await update(child: updated)
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
