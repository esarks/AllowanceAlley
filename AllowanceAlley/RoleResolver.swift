import Foundation
import Supabase

struct UserContext: Decodable {
    let familyId: UUID
    let role: String
    let childUserId: UUID? // present when role == "child"
}

enum RoleResolver {
    /// Parent: row in `families` where owner_id == auth.uid()
    /// Child:  row in `family_members` where user_id == auth.uid()
    static func resolve(using client: SupabaseClient) async throws -> UserContext {
        // Newer SDKs return a session via async/throws
        let session = try await client.auth.session
        let userId: UUID = session.user.id   // <-- UUID, not String

        // 1) Are they the owner of a family? -> parent
        struct FamilyRow: Decodable { let id: UUID; let owner_id: UUID }
        let owned: [FamilyRow] = try await client.database
            .from("families")
            .select()
            .eq("owner_id", value: userId)   // compare UUID to uuid column
            .limit(1)
            .execute()
            .value

        if let fam = owned.first {
            return UserContext(familyId: fam.id, role: "parent", childUserId: nil)
        }

        // 2) Else, are they a member of a family? -> child
        struct MemberRow: Decodable { let family_id: UUID; let user_id: UUID }
        let memberships: [MemberRow] = try await client.database
            .from("family_members")
            .select()
            .eq("user_id", value: userId)    // UUID to uuid
            .limit(1)
            .execute()
            .value

        if let m = memberships.first {
            return UserContext(familyId: m.family_id, role: "child", childUserId: userId)
        }

        // 3) Signed in but not linked to a family
        throw NSError(domain: "RoleResolver",
                      code: 404,
                      userInfo: [NSLocalizedDescriptionKey: "No family found for this user."])
    }
}
