// ContentView.swift
import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      HomeView()
        .tabItem { Label("Home", systemImage: "house") }

      // Supply required params
      ChoresView(
        familyId: UUID(),   // TODO: replace with real family id
        childId: nil        // or a real child id
      )
      .tabItem { Label("Chores", systemImage: "checkmark.circle") }

      RewardsView(
        familyId: UUID(),   // TODO: replace with real family id
        childId: nil
      )
      .tabItem { Label("Rewards", systemImage: "gift") }

      ProfileView()
        .tabItem { Label("Profile", systemImage: "person.crop.circle") }
    }
  }
}
