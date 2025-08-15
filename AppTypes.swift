import Foundation

public enum UserRole: String, Codable, Equatable {
    case parent, child
}

public struct RoleContext: Equatable {
    public let familyId: String
    public let role: UserRole
    public init(familyId: String, role: UserRole) {
        self.familyId = familyId
        self.role = role
    }
}

public enum AppStage: Equatable {
    case unauth
    case needsSetup
    case ready(RoleContext)
    case error(String)
}
