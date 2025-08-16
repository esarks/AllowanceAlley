import SwiftUI

public struct AAChoreListView: View {
    @EnvironmentObject private var chores: AAChoreStore
    @EnvironmentObject private var ledger: AALedgerStore
    @EnvironmentObject private var familyStore: FamilyStore

    @State private var showEditor = false
    @State private var selectedChildIdx = 0

    public init() {}

    private var activeChildId: UUID? {
        guard !familyStore.children.isEmpty else { return nil }
        return familyStore.children[selectedChildIdx].id
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let childId = activeChildId {
                    List {
                        ForEach(chores.chores(for: childId)) { chore in
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chore.title)
                                    HStack(spacing: 8) {
                                        if let due = chore.dueDate { Text(due, style: .date).font(.caption).foregroundStyle(.secondary) }
                                        Text("\(chore.points) pts").font(.caption).foregroundStyle(.secondary)
                                        if chore.recurrence != .none { Text(chore.recurrence.rawValue.capitalized).font(.caption2).padding(4).background(Color.secondary.opacity(0.1)).clipShape(Capsule()) }
                                    }
                                }
                                Spacer()
                                if !chore.isCompleted {
                                    Button("Done") {
                                        var c = chore; c.isCompleted = true
                                        chores.update(c)
                                        ledger.earn(chore.points, note: chore.title, childId: childId)
                                    }.buttonStyle(.borderedProminent)
                                } else {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }
                        }
                        .onDelete { idx in if let id = activeChildId { chores.delete(at: idx, for: id) } }
                    }
                } else {
                    ContentUnavailableView("No child yet", systemImage: "person.2", description: Text("Add a child on Home to start assigning chores."))
                }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Child", selection: $selectedChildIdx) {
                        ForEach(Array(familyStore.children.enumerated()), id: \.offset) { idx, child in
                            Text(child.name).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(familyStore.children.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showEditor = true } label { Image(systemName: "plus") }
                        .disabled(familyStore.children.isEmpty)
                }
            }
            .sheet(isPresented: $showEditor) {
                AAChoreEditorView { newChore in
                    chores.add(newChore)
                    showEditor = false
                }.environmentObject(familyStore)
            }
        }
    }
}
