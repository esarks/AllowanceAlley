struct Chore: Identifiable, Codable, Equatable {
    var id: UUID
    var parentUserId: UUID      // <-- UUID
    var childId: UUID?
    var title: String
    var notes: String?
    var dueDate: Date?
    var points: Int
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case parentUserId = "parent_user_id"
        case childId      = "child_id"
        case title, notes
        case dueDate      = "due_date"
        case points
        case isCompleted  = "is_completed"
        case completedAt  = "completed_at"
        case createdAt    = "created_at"
    }

    static let dateOnly: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
