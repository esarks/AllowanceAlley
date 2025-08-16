import SwiftUI

public struct AADashboardView: View {
    @EnvironmentObject private var familyStore: FamilyStore
    @EnvironmentObject private var ledger: AALedgerStore
    @EnvironmentObject private var chores: AAChoreStore

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Family Summary") {
                    ForEach(familyStore.children) { child in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(child.name).font(.headline)
                                Text("This week: \(ledger.pointsThisWeek(for: child.id)) pts").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(ledger.totalPoints(for: child.id)) pts")
                        }
                    }
                }
                Section("Quick Links") {
                    NavigationLink("Chores") { AAChoreListView() }
                    NavigationLink("Rewards Catalog") { AARewardsCatalogView() }
                    NavigationLink("Redeem Rewards") { AARewardsRedeemView() }
                    NavigationLink("Approvals (Parent)") { AARewardsApprovalView() }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}
