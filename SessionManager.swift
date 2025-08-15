import Foundation
import Supabase

struct UserContext: Decodable {
    let familyId: UUID
    let role: String              // "parent" or "child"
    let childUserId: UUID?        // present when role == "child"
}

enum SessionManager {
    static func resolveContext(using client: SupabaseClient, session: Session) async throws -> UserContext? {
        let userId: UUID = session.user.id

        struct FamilyRow: Decodable { let id: UUID; let owner_id: UUID }
        let owned: [FamilyRow] = try await client.database
            .from("families")
            .select()
            .eq("owner_id", value: userId)
            .limit(1)
            .execute()
            .value

        if let fam = owned.first {
            return UserContext(familyId: fam.id, role: "parent", childUserId: nil)
        }

        struct MemberRow: Decodable { let family_id: UUID; let user_id: UUID }
        let memberships: [MemberRow] = try await client.database
            .from("family_members")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value

        if let m = memberships.first {
            return UserContext(familyId: m.family_id, role: "child", childUserId: userId)
        }

        return nil
    }

    static func createFamily(using client: SupabaseClient, session: Session, name: String) async throws -> UserContext {
        let userId: UUID = session.user.id

        struct InsertedFamily: Decodable { let id: UUID; let owner_id: UUID }
        let inserted: [InsertedFamily] = try await client.database
            .from("families")
            .insert([[ "name": name, "owner_id": userId ]], returning: .representation)
            .select()
            .limit(1)
            .execute()
            .value

        guard let fam = inserted.first else {
            throw NSError(domain: "SessionManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Family create failed."])
        }
        return UserContext(familyId: fam.id, role: "parent", childUserId: nil)
    }
}
