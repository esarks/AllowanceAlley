import SwiftUI

public struct AARewardsCatalogView: View {
    @EnvironmentObject private var rewards: AARewardStore
    @State private var name = ""
    @State private var cost = 5

    public init() {}

    public var body: some View {
        Form {
            Section("New Reward") {
                TextField("Name", text: $name)
                Stepper("Cost: \(cost) pts", value: $cost, in: 1...100)
                Button("Add") {
                    rewards.addReward(.init(name: name, cost: cost))
                    name = ""; cost = 5
                }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Section("Catalog") {
                List {
                    ForEach(rewards.rewards) { r in
                        HStack { Text(r.name); Spacer(); Text("\(r.cost) pts").foregroundStyle(.secondary) }
                    }.onDelete(perform: rewards.deleteRewards)
                }
            }
        }
        .navigationTitle("Rewards Catalog")
    }
}

public struct AARewardsRedeemView: View {
    @EnvironmentObject private var rewards: AARewardStore
    @EnvironmentObject private var ledger: AALedgerStore
    @EnvironmentObject private var familyStore: FamilyStore

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
                        Section("Points: \(ledger.totalPoints(for: childId))") { EmptyView() }
                        ForEach(rewards.rewards) { r in
                            HStack {
                                Text(r.name)
                                Spacer()
                                Text("\(r.cost) pts").foregroundStyle(.secondary)
                                Button("Request") { rewards.request(r, for: childId) }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(ledger.totalPoints(for: childId) < r.cost)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No child yet", systemImage: "person.2", description: Text("Add a child on Home to request rewards."))
                }
            }
            .navigationTitle("Redeem Rewards")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Child", selection: $selectedChildIdx) {
                        ForEach(Array(familyStore.children.enumerated()), id: \.offset) { idx, child in
                            Text(child.name).tag(idx)
                        }
                    }.pickerStyle(.menu)
                    .disabled(familyStore.children.isEmpty)
                }
            }
        }
    }
}

public struct AARewardsApprovalView: View {
    @EnvironmentObject private var rewards: AARewardStore
    @EnvironmentObject private var ledger: AALedgerStore

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                ForEach(rewards.requests) { req in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(req.reward.name)
                            Text(req.at, style: .date).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(req.status.rawValue.capitalized).foregroundStyle(.secondary)
                        if req.status == .requested {
                            Button("Approve") { rewards.approve(req); _ = ledger.redeem(req.reward.cost, note: req.reward.name, childId: req.childId) }
                                .buttonStyle(.borderedProminent)
                            Button("Reject") { rewards.reject(req) }
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Approvals")
        }
    }
}
