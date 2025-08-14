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
    let owner_id: String            // <- TEXT in DB, keep as String
}

private struct NewFamily: Codable {
    let id: UUID
    let name: String
    let owner_id: String
}

private struct NewMember: Codable {
    let family_id: UUID
    let child_name: String
    var age: Int?
    var role: String? = "child"     // avoid “immutable won’t be decoded” warning
}

final class FamilyService {
    // Your SDK version: use .database (postgrest accessor isn’t present)
    private let db = SupabaseManager.shared.client.database
    private let auth = SupabaseManager.shared.client.auth

    /// Ensure the current user has a family; create one if not.
    func getOrCreateMyFamily(named name: String = "My Family") async throws -> UUID {
        guard let session = try? await auth.session else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        let ownerID: String = session.user.id

        // Try to load existing family
        if let fam = try? await fetchOwnedFamily(ownerID: ownerID) {
            return fam.id
        }

        // Create new and return id
        let created = try await insertFamily(ownerID: ownerID, name: name)
        return created.id
    }

    // MARK: - Members

    /// All members for a family
    func getMembers(familyId: UUID) async throws -> [MemberDTO] {
        let resp: PostgrestResponse<[MemberDTO]> = try await db
            .from("members")
            .select()
            .eq("family_id", value: familyId)         // UUID column → pass UUID
            .order("child_name", ascending: true)
            .execute()
        return resp.value
    }

    /// Add a child member
    @discardableResult
    func addChild(familyId: UUID, name: String, age: Int?) async throws -> MemberDTO {
        let new = NewMember(family_id: familyId, child_name: name, age: age)

        // Insert
        _ = try await db.from("members").insert(new).execute()

        // Read back the inserted row (latest by id)
        let resp: PostgrestResponse<MemberDTO> = try await db
            .from("members")
            .select()
            .eq("family_id", value: familyId)
            .eq("child_name", value: name)
            .order("id", ascending: false)
            .limit(1)
            .single()
            .execute()
        return resp.value
    }

    // MARK: - Private helpers (owner_id is TEXT/String)

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

        // Insert
        _ = try await db.from("families").insert(new).execute()

        // Select by id we just generated
        let resp: PostgrestResponse<FamilyDTO> = try await db
            .from("families")
            .select()
            .eq("id", value: new.id)
            .single()
            .execute()
        return resp.value
    }
}
