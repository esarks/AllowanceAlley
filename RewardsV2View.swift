import SwiftUI

public struct RewardsV2View: View {
    @EnvironmentObject private var ledger: AALedgerStore
    @EnvironmentObject private var familyStore: FamilyStore

    private let injectedChildId: UUID?
    public init(childId: UUID? = nil) { self.injectedChildId = childId }

    private var activeChildId: UUID? {
        injectedChildId ?? familyStore.children.first?.id
    }

    @State private var rewards = AARewardsCatalog.demo
    @State private var showAlert = false
    @State private var alertText = ""

    public var body: some View {
        NavigationStack {
            if let childId = activeChildId {
                List {
                    Section("Points: \(ledger.totalPoints(for: childId))") { EmptyView() }
                    ForEach(rewards) { reward in
                        HStack {
                            Text(reward.name)
                            Spacer()
                            Text("\(reward.cost) pts")
                            Button("Redeem") {
                                let ok = ledger.redeem(reward.cost, note: reward.name, childId: childId)
                                alertText = ok ? "Redeemed \(reward.name)" : "Not enough points"
                                showAlert = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(ledger.totalPoints(for: childId) < reward.cost)
                        }
                    }
                }
                .navigationTitle("Rewards (V2)")
                .alert(alertText, isPresented: $showAlert) { Button("OK", role: .cancel) {} }
            } else {
                ContentUnavailableView("No child yet", systemImage: "person.2", description: Text("Add a child on Home to start redeeming."))
                    .navigationTitle("Rewards (V2)")
            }
        }
    }
}
