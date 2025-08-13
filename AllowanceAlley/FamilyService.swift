import Supabase
import Foundation

struct MemberDTO: Decodable, Identifiable {
    let id: UUID
    let family_id: UUID
    let user_id: UUID?
    let child_name: String?
    let age: Int?
    let role: String
}

struct FamilyDTO: Decodable { let id: UUID }

final class FamilyService {
    private let db = SupabaseManager.shared.client.database
    private let auth = SupabaseManager.shared.client.auth

    // Ensure the user has a family; create one if not.
    func getOrCreateMyFamily(named name: String = "My Family") async throws -> UUID {
        let uid = try await auth.session.user.id

        // Try owned family first
        if let fam: FamilyDTO = try await db.from("families")
            .select("id")
            .eq("owner_id", value: uid)
            .limit(1)
            .single()
            .execute()
            .decoded() {
            return fam.id
        }

        // Create one if none exists (RLS allows owner insert)
        let created: FamilyDTO = try await db.from("families")
            .insert([
                "owner_id": uid.uuidString,
                "name": name
            ], returning: .representation)
            .single()
            .execute()
            .decoded()
        return created.id
    }

    func members(familyId: UUID) async throws -> [MemberDTO] {
        try await db.from("family_members")
            .select()
            .eq("family_id", value: familyId)
            .order("created_at", ascending: true)
            .execute()
            .decoded()
    }

    func addChild(familyId: UUID, name: String, age: Int?) async throws {
        _ = try await db.from("family_members")
            .insert([
                "family_id": familyId.uuidString,
                "role": "child",
                "child_name": name,
                "age": age as Any
            ])
            .execute()
    }
}
