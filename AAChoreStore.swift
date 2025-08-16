import Foundation

public enum AARecurrence: String, CaseIterable, Codable { case none, daily, weekly, monthly }

public struct AAChore: Identifiable, Codable, Equatable {
    public var id = UUID()
    public var title: String
    public var detail: String
    public var dueDate: Date?
    public var recurrence: AARecurrence
    public var points: Int
    public var assigneeId: UUID
    public var photoRequired: Bool
    public var isCompleted: Bool = false
    public var approved: Bool = false
}

@MainActor
public final class AAChoreStore: ObservableObject {
    @Published public private(set) var chores: [AAChore] = []

    public init() { load() }

    public func chores(for childId: UUID) -> [AAChore] {
        chores.filter { $0.assigneeId == childId }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    public func add(_ c: AAChore) { chores.append(c); save() }
    public func update(_ c: AAChore) { if let i = chores.firstIndex(where: { $0.id == c.id }) { chores[i] = c; save() } }
    public func delete(at offsets: IndexSet, for childId: UUID) {
        let ids = chores(for: childId).enumerated().filter { offsets.contains($0.offset) }.map { $0.element.id }
        chores.removeAll { ids.contains($0.id) }; save()
    }

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("aa_chores.json")
    }
    private func save() {
        do { let data = try JSONEncoder().encode(chores); try data.write(to: fileURL, options: .atomic) }
        catch { print("AAChoreStore save error:", error) }
    }
    private func load() {
        do { let data = try Data(contentsOf: fileURL); chores = try JSONDecoder().decode([AAChore].self, from: data) }
        catch { chores = [] }
    }
}
