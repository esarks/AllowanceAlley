import Foundation

enum RoleResolverError: Error { case needsSetup }

enum RoleResolver {
    static func resolve(using client: SupabaseService) async throws -> AppTypes.RoleContext {
        // TODO: Replace with real Supabase queries:
        // - If user has no family/profile -> throw .needsSetup
        // - Else return RoleContext with familyId + role
        let demoHasFamily = true
        if !demoHasFamily { throw RoleResolverError.needsSetup }
        return AppTypes.RoleContext(familyId: "demo-family", role: .parent)
    }
}
