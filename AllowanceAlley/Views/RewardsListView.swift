import SwiftUI

struct RewardsListView: View {
    @State private var vm: RewardsViewModel
    private let childId: UUID

    init(familyId: UUID, childId: UUID) {
        self.childId = childId
        _vm = State(initialValue: .init(repo: RewardsDI.makeRepo(), familyId: familyId, role: .child, childId: childId))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.loading {
                    ProgressView("Loading…")
                } else if let error = vm.error {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if vm.rewards.isEmpty {
                    ContentUnavailableView("No rewards yet", systemImage: "gift", description: Text("Ask a parent to add some!"))
                } else {
                    List(vm.rewards) { r in
                        HStack {
                            Image(systemName: "gift")
                            VStack(alignment: .leading) {
                                Text(r.title).font(.headline)
                                Text("\(r.costPoints) pts").font(.subheadline)
                            }
                            Spacer()
                            Button("Request") {
                                Task { await vm.request(r) }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .navigationTitle("Rewards")
            .task { await vm.load() }
        }
    }
}
