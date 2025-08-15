import SwiftUI

struct RewardCatalogView: View {
    @State private var vm: RewardsViewModel
    @State private var draft = Reward(title: "", details: "", costPoints: 0)

    init(familyId: UUID) {
        _vm = State(initialValue: .init(repo: RewardsDI.makeRepo(), familyId: familyId, role: .parent))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Add / Edit Reward") {
                    VStack(alignment: .leading, spacing: DS.spacing) {
                        TextField("Title", text: $draft.title)
                        TextField("Details", text: $draft.details)
                        Stepper(value: $draft.costPoints, in: 0...500) {
                            Text("Cost: \(draft.costPoints) pts")
                        }
                        HStack {
                            Button("Save") { Task { await vm.save(draft); await vm.load() } }
                                .buttonStyle(.borderedProminent)
                            Button("Reset") { draft = Reward(title: "", details: "", costPoints: 0) }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Active Rewards") {
                    ForEach(vm.rewards) { r in
                        HStack {
                            Image(systemName: "gift")
                            VStack(alignment: .leading) {
                                Text(r.title).font(.headline)
                                Text("\(r.costPoints) pts").font(.subheadline)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                Task { await vm.archive(r); await vm.load() }
                            } label: { Image(systemName: "archivebox") }
                        }
                    }
                }
            }
            .navigationTitle("Reward Catalog")
            .task { await vm.load() }
        }
    }
}
