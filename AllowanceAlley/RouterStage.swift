// RouterStage.swift
import Foundation

enum UserRole: Equatable { case parent, child }

struct RoleContext: Equatable {
    let familyId: String
    let role: UserRole
}

enum RouterStage: Equatable {
    case unauth
    case needsSetup
    case ready(RoleContext)
    case error(String)
}
