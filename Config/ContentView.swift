import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                ChoresTabView() // uses FamilyStore to pass IDs into ChoresView
            }
            .tabItem { Label("Chores", systemImage: "checkmark.circle") }

            NavigationStack {
                RewardsListView() // reads RewardsViewModel via @EnvironmentObject
            }
            .tabItem { Label("Rewards", systemImage: "gift") }

            NavigationStack {
                ProfileTabView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
