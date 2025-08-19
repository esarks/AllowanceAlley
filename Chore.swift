import Foundation

/// Matches the `public.chores` table.
struct Chore: Identifiable, Codable, Equatable {
    let id: UUID
    let parent_user_id: UUID
    var child_id: UUID?
    var title: String
    var notes: String?
    /// Stored as "yyyy-MM-dd" from PostgREST; keep as String to avoid decoding headaches.
    var due_date: String?
    var points: Int
    var is_completed: Bool
    var created_at: String?

    enum CodingKeys: String, CodingKey {
        case id, parent_user_id, child_id, title, notes, due_date, points, is_completed, created_at
    }
}

extension Chore {
    /// Shared "yyyy-MM-dd" formatter.
    static let dateOnly: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    var dueDateAsDate: Date? {
        guard let s = due_date else { return nil }
        return Chore.dateOnly.date(from: s)
    }

    func with(dueDate: Date?) -> Chore {
        var copy = self
        copy.due_date = dueDate.map { Chore.dateOnly.string(from: $0) }
        return copy
    }
}
