
import SwiftUI

/// Optional tab container that uses the new functional V2 screens.
/// This does NOT replace your existing ContentView.
/// To try it, set `ContentViewV2()` as the root in `AllowanceAlleyApp` temporarily.
public struct ContentViewV2: View {
    public init() {}
    public var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            ChoresV2View()
                .tabItem { Label("Chores", systemImage: "checkmark.circle") }

            RewardsV2View()
                .tabItem { Label("Rewards", systemImage: "gift") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
