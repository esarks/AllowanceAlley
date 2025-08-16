import SwiftUI

public struct ContentViewBRD: View {
    public init() {}
    public var body: some View {
        TabView {
            AADashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            AAChoreListView()
                .tabItem { Label("Chores", systemImage: "checkmark.circle") }
            AARewardsRedeemView()
                .tabItem { Label("Rewards", systemImage: "gift") }
            NavigationStack {
                List {
                    NavigationLink("Rewards Catalog (Parent)") { AARewardsCatalogView() }
                    NavigationLink("Approvals (Parent)") { AARewardsApprovalView() }
                }.navigationTitle("Admin")
            }.tabItem { Label("Admin", systemImage: "gearshape") }
        }
    }
}
