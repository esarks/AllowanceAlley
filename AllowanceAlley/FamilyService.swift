import Foundation
import Supabase

struct MemberDTO: Codable, Identifiable {
    let id: UUID
    let family_id: UUID
    let user_id: String?
    let child_name: String?
    let age: Int?
    let role: String
}

struct FamilyDTO: Codable, Identifiable {
    let id: UUID
    let name: String?
    let owner_id: UUID       // match your schema; change to String if your column is text
}

private struct NewFamily: Codable {
    let id: UUID
    let name: String
    let owner_id: UUID
}

final class FamilyService {
    // Your current SDK has `database`; deprecation warning is OK.
    private let db = SupabaseManager.shared.client.database
    private let auth = SupabaseManager.shared.client.auth

    /// Ensure the user has a family; create one if not.
    func getOrCreateMyFamily(named name: String = "My Family") async throws -> UUID {
        // session may be sync/async depending on SDK; both compile:
        let session = try? await auth.session
        guard let session else {
            throw NSError(domain: "Auth", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }

        let ownerID: UUID = session.user.id   // if your project stores owner_id as text, change type to String above

        if let existing = try? await fetchOwnedFamily(ownerID: ownerID) {
            return existing.id
        }

        let created = try await insertFamily(ownerID: ownerID, name: name)
        return created.id
    }

    // MARK: - Queries

    private func fetchOwnedFamily(ownerID: UUID) async throws -> FamilyDTO {
        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("owner_id", value: ownerID)
            .limit(1)
            .single()
            .execute()
        return resp.value
    }

    private func insertFamily(ownerID: UUID, name: String) async throws -> FamilyDTO {
        let new = NewFamily(id: UUID(), name: name, owner_id: ownerID)

        // Insert first (don’t rely on returning:)
        _ = try await db
            .from("families")
            .insert(new)
            .execute()

        // Fetch the row we just created
        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("id", value: new.id)
            .single()
            .execute()
        return resp.value
    }
}
