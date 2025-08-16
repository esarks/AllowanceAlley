import SwiftUI

/// Root tab container for the demo build. Wires real Rewards screens so the tab actually does something.
struct ContentView: View {
    // Home tab needs this
    @EnvironmentObject var store: FamilyStore

    // Rewards screens share a single view model via environment
    @StateObject private var rewardsVM = RewardsViewModel(repository: InMemoryRewardsRepository())

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            // Keep a placeholder for chores for now (BRD phase 2 will flesh this out)
            ChoresView()
                .tabItem { Label("Chores", systemImage: "checkmark.circle") }

            // New: real Rewards flow (list + Catalog + Approvals via toolbar)
            RewardsHomeView()
                .environmentObject(rewardsVM)
                .tabItem { Label("Rewards", systemImage: "gift") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
