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
    let owner_id: UUID         // ← if your DB column is TEXT, change to String
}

private struct NewFamily: Codable {
    let id: UUID
    let name: String
    let owner_id: UUID
}

final class FamilyService {
    private let db = SupabaseManager.shared.client.database   // deprecation warning ok
    private let auth = SupabaseManager.shared.client.auth

    func getOrCreateMyFamily(named name: String = "My Family") async throws -> UUID {
        guard let session = try? await auth.session else {
            throw NSError(domain: "Auth", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        let ownerID: UUID = session.user.id // if TEXT column, use: let ownerID = session.user.id

        if let existing = try? await fetchOwnedFamily(ownerID: ownerID) {
            return existing.id
        }
        let created = try await insertFamily(ownerID: ownerID, name: name)
        return created.id
    }

    private func fetchOwnedFamily(ownerID: UUID) async throws -> FamilyDTO {
        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("owner_id", value: ownerID) // if TEXT column, this is String
            .limit(1)
            .single()
            .execute()
        return resp.value
    }

    private func insertFamily(ownerID: UUID, name: String) async throws -> FamilyDTO {
        let new = NewFamily(id: UUID(), name: name, owner_id: ownerID)

        _ = try await db.from("families").insert(new).execute() // simple insert

        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("id", value: new.id)
            .single()
            .execute()
        return resp.value
    }
}
