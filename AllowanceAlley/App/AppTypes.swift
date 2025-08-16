import Foundation

enum AppTypes {
  enum UserRole: String, Codable, Equatable { case parent, child }

  struct RoleContext: Codable, Equatable {
    let familyId: String
    let role: UserRole
  }

  enum Stage: Equatable {
    case unauth
    case needsSetup
    case ready(RoleContext)
    case error(String)

    static func == (l: Stage, r: Stage) -> Bool {
      switch (l, r) {
      case (.unauth, .unauth), (.needsSetup, .needsSetup): return true
      case let (.ready(a), .ready(b)): return a == b
      case let (.error(a), .error(b)): return a == b
      default: return false
      }
    }
  }
}
