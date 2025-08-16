import SwiftUI

private struct AAChore: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var points: Int
    var done = false
}

public struct ChoresV2View: View {
    @EnvironmentObject private var ledger: AALedgerStore
    @EnvironmentObject private var familyStore: FamilyStore

    private let injectedChildId: UUID?
    public init(childId: UUID? = nil) { self.injectedChildId = childId }

    private var activeChildId: UUID? {
        injectedChildId ?? familyStore.children.first?.id
    }

    @State private var chores: [AAChore] = [
        .init(title: "Make bed",      points: 2),
        .init(title: "Feed the dog",  points: 1),
        .init(title: "Clean room",    points: 3),
        .init(title: "Do homework",   points: 4)
    ]

    public var body: some View {
        NavigationStack {
            if let childId = activeChildId {
                List {
                    ForEach($chores) { $chore in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(chore.title)
                                Text("\(chore.points) pts").font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $chore.done).labelsHidden()
                        }
                        .contentShape(Rectangle())
                        .onChange(of: chore.done) { done in
                            if done { ledger.earn(chore.points, note: chore.title, childId: childId) }
                        }
                    }
                    .onDelete { chores.remove(atOffsets: $0) }
                }
                .navigationTitle("Chores (V2)")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { chores.append(.init(title: "New chore \(chores.count + 1)", points: 1)) } label { Image(systemName: "plus") }
                    }
                }
            } else {
                ContentUnavailableView("No child yet", systemImage: "person.2", description: Text("Add a child on Home to start earning points."))
                    .navigationTitle("Chores (V2)")
            }
        }
    }
}
