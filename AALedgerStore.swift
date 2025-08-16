import Foundation

public struct AALedgerEntry: Codable, Identifiable, Equatable {
    public enum Kind: String, Codable { case earn, redeem }
    public var id = UUID()
    public var childId: UUID
    public var kind: Kind
    public var points: Int
    public var note: String
    public var at: Date = .init()
}

@MainActor
public final class AALedgerStore: ObservableObject {
    @Published public private(set) var entries: [AALedgerEntry] = []

    public init() { load() }

    public func totalPoints(for childId: UUID) -> Int {
        entries.reduce(0) { acc, e in
            guard e.childId == childId else { return acc }
            return acc + (e.kind == .earn ? e.points : -e.points)
        }
    }

    public func pointsThisWeek(for childId: UUID) -> Int {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return entries.filter { $0.childId == childId && $0.at >= startOfWeek }.reduce(0) { $0 + ($1.kind == .earn ? $1.points : -$1.points) }
    }

    public func earn(_ pts: Int, note: String, childId: UUID) {
        guard pts > 0 else { return }
        entries.append(.init(childId: childId, kind: .earn, points: pts, note: note))
        save()
    }

    @discardableResult
    public func redeem(_ pts: Int, note: String, childId: UUID) -> Bool {
        guard pts > 0 else { return false }
        if totalPoints(for: childId) < pts { return false }
        entries.append(.init(childId: childId, kind: .redeem, points: pts, note: note))
        save()
        return true
    }

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("aa_ledger.json")
    }
    private func save() {
        do { let data = try JSONEncoder().encode(entries); try data.write(to: fileURL, options: .atomic) }
        catch { print("AALedgerStore save error:", error) }
    }
    private func load() {
        do { let data = try Data(contentsOf: fileURL); entries = try JSONDecoder().decode([AALedgerEntry].self, from: data) }
        catch { entries = [] }
    }
}
