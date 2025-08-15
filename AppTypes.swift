import Foundation

public enum AppTypes {
    // MARK: - Shared user/role types
    public enum UserRole: String, Codable, Equatable { case parent, child }

    public struct RoleContext: Equatable {
        public let familyId: String
        public let role: UserRole
        public init(familyId: String, role: UserRole) {
            self.familyId = familyId
            self.role = role
        }
    }

    // MARK: - Routing stage (formerly `RouterStage`)
    public enum Stage: Equatable {
        case unauth
        case needsSetup
        case ready(RoleContext)
        case error(String)
    }
}
