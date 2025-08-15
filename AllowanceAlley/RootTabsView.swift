// RootTabsView.swift
import SwiftUI
struct RootTabsView: View {
  let context: AppTypes.RoleContext
  var body: some View {
    TabView {
      Text("Home (\(context.role == .parent ? "Parent" : "Child"))")
        .tabItem { Label("Home", systemImage: "house") }
      ProfileView()
        .tabItem { Label("Profile", systemImage: "person.circle") }
    }
  }
}

// SetupFamilyView.swift
import SwiftUI
struct SetupFamilyView: View {
  var onFinished: () -> Void
  var body: some View {
    VStack(spacing: 12) {
      Text("Family setup").font(.title2)
      Button("Finish Setup") { onFinished() }
    }.padding()
  }
}

// ProfileView.swift
import SwiftUI
struct ProfileView: View {
  var body: some View { Text("Profile").padding() }
}
