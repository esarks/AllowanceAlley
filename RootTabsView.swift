import SwiftUI

struct RootTabsView: View {
    let context: RoleContext

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ChoresView()
                .tabItem { Label("Chores", systemImage: "checkmark.circle") }
            RewardsView()
                .tabItem { Label("Rewards", systemImage: "gift") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}