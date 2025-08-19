import Foundation

struct Child: Codable, Identifiable, Equatable {
    var id: UUID
    var parentUserId: String
    var name: String
    var birthdate: Date?
    var avatarUrl: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case parentUserId = "parent_user_id"
        case name
        case birthdate
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }

    var age: Int? {
        guard let b = birthdate else { return nil }
        return Calendar.current.dateComponents([.year], from: b, to: Date()).year
    }
}