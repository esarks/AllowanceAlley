import Foundation

struct Child: Identifiable, Codable, Equatable {
    var id: UUID
    var parentUserId: UUID
    var name: String
    var birthdate: Date?
    var avatarURL: URL?

    var age: Int? {
        guard let b = birthdate else { return nil }
        return Calendar.current.dateComponents([.year], from: b, to: Date()).year
    }

    enum CodingKeys: String, CodingKey {
        case id
        case parentUserId = "parent_user_id"
        case name
        case birthdate
        case avatarURL = "avatar_url"
    }
}
