// RootTabsView.swift
import SwiftUI

struct RootTabsView: View {
    let context: RoleContext

    var body: some View {
        TabView {
            Text("Home for \(context.role == .parent ? "Parent" : "Child")")
                .tabItem { Label("Home", systemImage: "house") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
