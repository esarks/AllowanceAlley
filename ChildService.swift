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

    // CREATE
    func add(name: String, birthdate: Date?, avatarData: Data?) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await currentUserId()
            var newChild = Child(
                id: UUID(),
                parentUserId: uid.uuidString,
                name: name,
                birthdate: birthdate,
                avatarUrl: nil,
                createdAt: Date()
            )

            if let data = avatarData {
                let path = "avatars/\(newChild.id.uuidString).jpg"
                try await client.storage
                    .from("avatars")
                    .upload(path: path, file: data,
                            options: FileOptions(contentType: "image/jpeg", upsert: true))
                newChild.avatarUrl = path
            }

            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .insert(newChild)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // UPDATE
    func update(_ child: Child) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let _: PostgrestResponse<[Child]> = try await client.database
                .from("children")
                .update(child)
                .eq("id", value: child.id.uuidString)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // DELETE
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
}