import Foundation

/// App model for a child profile backed by the `public.children` table.
/// - Note: `birthdate` is a Postgres `DATE` column. Supabase serializes it as "yyyy-MM-dd".
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

    // Shared date-only formatter for Postgres DATE <-> Date
    static let dateOnly: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(id: UUID,
         parentUserId: String,
         name: String,
         birthdate: Date?,
         avatarUrl: String?,
         createdAt: Date?) {
        self.id = id
        self.parentUserId = parentUserId
        self.name = name
        self.birthdate = birthdate
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
    }

    // Custom decode:
    // - birthdate: accept "yyyy-MM-dd" string (preferred) or a Date if the backend sends one.
    // - other fields decode normally.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        parentUserId = try c.decode(String.self, forKey: .parentUserId)
        name = try c.decode(String.self, forKey: .name)

        if let s = try? c.decode(String.self, forKey: .birthdate) {
            birthdate = Child.dateOnly.date(from: s)
        } else if let d = try? c.decode(Date.self, forKey: .birthdate) {
            birthdate = d
        } else {
            birthdate = nil
        }

        avatarUrl = try? c.decode(String.self, forKey: .avatarUrl)
        createdAt = try? c.decode(Date.self, forKey: .createdAt)
    }

    // Custom encode:
    // - birthdate: write as "yyyy-MM-dd" when present so PostgREST DATE accepts it.
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(parentUserId, forKey: .parentUserId)
        try c.encode(name, forKey: .name)
        if let d = birthdate {
            try c.encode(Child.dateOnly.string(from: d), forKey: .birthdate)
        }
        try c.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try c.encodeIfPresent(createdAt, forKey: .createdAt) // usually omitted on insert
    }
}
