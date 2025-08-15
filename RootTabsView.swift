import SwiftUI

public struct RootTabsView: View {
    let context: RoleContext

    public init(context: RoleContext) {
        self.context = context
    }

    public var body: some View {
        TabView {
            Text("Home (\(context.role == .parent ? "Parent" : "Child"))")
                .tabItem { Label("Home", systemImage: "house") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
