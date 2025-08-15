import SwiftUI

struct ChoresView: View {
    let familyId: UUID
    var childId: UUID? = nil

    var body: some View {
        NavigationStack {
            List {
                if let childId {
                    Section("My Chores") {
                        Label("Child: \(childId.uuidString.prefix(8))…", systemImage: "person")
                        Label("Sample chore A", systemImage: "checkmark.circle")
                        Label("Sample chore B", systemImage: "checkmark.circle")
                    }
                } else {
                    Section("Chores") {
                        Label("Assign chores to kids", systemImage: "square.and.pencil")
                        Label("Track completions", systemImage: "clock")
                    }
                }
            }
            .navigationTitle("Chores")
        }
    }
}
