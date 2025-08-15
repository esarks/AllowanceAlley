
import SwiftUI

private struct AAChore: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var points: Int
    var done = false
}

struct ChoresV2View: View {
    @EnvironmentObject private var ledger: AALedgerStore

    // Demo child id — replace with your selected child when wiring.
    private let childId: UUID = UUID()

    @State private var chores: [AAChore] = [
        .init(title: "Make bed",      points: 2),
        .init(title: "Feed the dog",  points: 1),
        .init(title: "Clean room",    points: 3),
        .init(title: "Do homework",   points: 4)
    ]

    var body: some View {
        NavigationStack {
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
                    .onChange(of: chore.done) { newValue in
                        if newValue {
                            ledger.earn(chore.points, note: chore.title, childId: childId)
                        }
                    }
                }
                .onDelete { chores.remove(atOffsets: $0) }
            }
            .navigationTitle("Chores (V2)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        chores.append(.init(title: "New chore \(chores.count + 1)", points: 1))
                    } label { Image(systemName: "plus") }
                }
            }
        }
    }
}
