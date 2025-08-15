import Foundation

enum RoleResolverError: Error { case needsSetup }

enum RoleResolver {
    static func resolve(using client: SupabaseService) async throws -> RoleContext {
        let demoHasFamily = true   // set to False to force needsSetup
        if !demoHasFamily { throw RoleResolverError.needsSetup }
        return RoleContext(familyId: "demo-family", role: .parent)
    }
}
