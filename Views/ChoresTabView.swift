import SwiftUI

struct ChoresTabView: View {
    @EnvironmentObject var store: FamilyStore

    var body: some View {
        Group {
            if let firstChild = store.children.first {
                // If your store uses `id` (not `familyId`), change the next line to: store.id
                ChoresView(familyId: store.familyId, childId: firstChild.id)
            } else {
                VStack(spacing: 12) {
                    Text("No kids yet").font(.headline)
                    Text("Tap + on Home to add a child.")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Chores")
    }
}
