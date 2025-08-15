
import Foundation

// MARK: - Ledger Models

struct AALedgerEntry: Codable, Identifiable, Equatable {
    enum Kind: String, Codable { case earn, redeem }
    var id = UUID()
    var childId: UUID
    var kind: Kind
    var points: Int
    var note: String
    var at: Date = .init()
}

// MARK: - Store

@MainActor
final class AALedgerStore: ObservableObject {
    @Published private(set) var entries: [AALedgerEntry] = []

    init() { load() }

    func totalPoints(for childId: UUID) -> Int {
        entries.reduce(0) { acc, e in
            guard e.childId == childId else { return acc }
            return acc + (e.kind == .earn ? e.points : -e.points)
        }
    }

    func earn(_ pts: Int, note: String, childId: UUID) {
        guard pts > 0 else { return }
        entries.append(.init(childId: childId, kind: .earn, points: pts, note: note))
        save()
    }

    @discardableResult
    func redeem(_ pts: Int, note: String, childId: UUID) -> Bool {
        guard pts > 0 else { return false }
        if totalPoints(for: childId) < pts { return false }
        entries.append(.init(childId: childId, kind: .redeem, points: pts, note: note))
        save()
        return true
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("aa_ledger.json")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("AALedgerStore save error:", error)
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([AALedgerEntry].self, from: data)
        } catch {
            entries = [] // first run
        }
    }
}
