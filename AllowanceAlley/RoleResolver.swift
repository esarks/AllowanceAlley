// RoleResolver.swift
import Foundation

enum RoleResolverError: Error {
    case needsSetup
}

enum RoleResolver {
    static func resolve(using client: SupabaseService) async throws -> RoleContext {
        // TODO: Replace with real Supabase queries:
        // If user has no family/profile row -> throw .needsSetup
        // Else return RoleContext with familyId + role
        let demoHasFamily = true
        if !demoHasFamily { throw RoleResolverError.needsSetup }
        return RoleContext(familyId: "demo-family", role: .parent)
    }
}
