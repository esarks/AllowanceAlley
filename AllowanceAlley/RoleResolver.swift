// RoleResolver.swift
import Foundation
enum RoleResolverError: Error { case needsSetup }
enum RoleResolver {
  static func resolve(using client: SupabaseService) async throws -> AppTypes.RoleContext {
    let demoHasFamily = true
    if !demoHasFamily { throw RoleResolverError.needsSetup }
    return AppTypes.RoleContext(familyId: "demo-family", role: .parent)
  }
}
