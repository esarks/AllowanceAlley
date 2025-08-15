import Foundation
import Supabase

struct UserContext: Decodable {
    let familyId: UUID
    let role: String            // "parent" | "child"
    let childUserId: UUID?      // present when role == "child"
}

enum RoleResolver {
    /// Determines the current user's family + role using your existing schema & RLS.
    static func resolve(using client: SupabaseClient) async throws -> UserContext {
        guard let session = try? await client.auth.session else {
            throw NSError(domain: "RoleResolver", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        let userId: UUID = session.user.id  // UUID in newer SDKs

        // 1) Parent? (owns a family)
        struct FamilyRow: Decodable { let id: UUID; let owner_id: UUID }
        let owned: [FamilyRow] = try await client.database
            .from("families")
            .select()
            .eq("owner_id", value: userId)   // compare UUID to uuid
            .limit(1)
            .execute()
            .value
        if let fam = owned.first {
            return UserContext(familyId: fam.id, role: "parent", childUserId: nil)
        }

        // 2) Child? (member of a family)
        struct MemberRow: Decodable { let family_id: UUID; let user_id: UUID }
        let memberships: [MemberRow] = try await client.database
            .from("family_members")
            .select()
            .eq("user_id", value: userId)    // compare UUID to uuid
            .limit(1)
            .execute()
            .value
        if let m = memberships.first {
            return UserContext(familyId: m.family_id, role: "child", childUserId: userId)
        }

        // 3) Signed in but not linked to a family -> needs setup
        throw NSError(domain: "RoleResolver", code: 404, userInfo: [NSLocalizedDescriptionKey: "No family found for this user."])
    }
}
