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
