import SwiftUI

struct RewardsView: View {
    let familyId: UUID
    var childId: UUID? = nil

    var body: some View {
        NavigationStack {
            List {
                Section("Rewards") {
                    Label("Movie Night – 50 pts", systemImage: "film")
                    Label("Ice Cream Trip – 75 pts", systemImage: "scooter")
                    Label("Extra Screen Time – 30 pts", systemImage: "tv")
                }
                if let childId {
                    Section("Child") {
                        Label("Child: \(childId.uuidString.prefix(8))…", systemImage: "person")
                    }
                }
            }
            .navigationTitle("Rewards")
        }
    }
}
