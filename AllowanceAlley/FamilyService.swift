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
    let owner_id: String   // TEXT in DB; matches session.user.id
}

private struct NewFamily: Codable {
    let id: UUID
    let name: String
    let owner_id: String
}

private struct NewMember: Codable {
    let family_id: UUID
    let child_name: String
    let age: Int?
    let role: String = "child"
}

final class FamilyService {
    // Prefer postgrest on latest SDK
    private let db = SupabaseManager.shared.client.postgrest
    private let auth = SupabaseManager.shared.client.auth

    /// Ensure the current user has a family; create one if not.
    func getOrCreateMyFamily(named name: String = "My Family") async throws -> UUID {
        guard let session = try? await auth.session else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        let ownerID = session.user.id

        if let fam = try? await fetchOwnedFamily(ownerID: ownerID) { return fam.id }

        let created = try await insertFamily(ownerID: ownerID, name: name)
        return created.id
    }

    /// All members for a family
    func getMembers(familyId: UUID) async throws -> [MemberDTO] {
        let resp: PostgrestResponse<[MemberDTO]> = try await db
            .from("members")
            .select()
            .eq("family_id", value: familyId.uuidString)
            .order("child_name", ascending: true)
            .execute()
        return resp.value
    }

    /// Add a child member
    @discardableResult
    func addChild(familyId: UUID, name: String, age: Int?) async throws -> MemberDTO {
        let new = NewMember(family_id: familyId, child_name: name, age: age)

        _ = try await db.from("members").insert(new).execute()

        let resp: PostgrestResponse<MemberDTO> = try await db
            .from("members")
            .select()
            .eq("family_id", value: familyId.uuidString)
            .eq("child_name", value: name)
            .order("id", ascending: false)
            .limit(1)
            .single()
            .execute()
        return resp.value
    }

    // MARK: - Private helpers

    private func fetchOwnedFamily(ownerID: String) async throws -> FamilyDTO {
        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("owner_id", value: ownerID)
            .limit(1)
            .single()
            .execute()
        return resp.value
    }

    private func insertFamily(ownerID: String, name: String) async throws -> FamilyDTO {
        let new = NewFamily(id: UUID(), name: name, owner_id: ownerID)

        _ = try await db.from("families").insert(new).execute()

        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("id", value: new.id.uuidString)
            .single()
            .execute()
        return resp.value
    }
}
