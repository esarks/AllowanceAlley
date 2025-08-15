import SwiftUI

public struct RootTabs: View {
    let familyId: UUID
    let role: String
    let childUserId: UUID?

    public init(familyId: UUID, role: String, childUserId: UUID?) {
        self.familyId = familyId
        self.role = role
        self.childUserId = childUserId
    }

    public var body: some View {
        TabView {
            if role == "parent" {
                // ----- Parent Tabs -----
                ContentUnavailableView(
                    "Dashboard",
                    systemImage: "house",
                    description: Text("Parent dashboard coming soon.")
                )
                .tabItem { Label("Dashboard", systemImage: "house") }

                ContentUnavailableView(
                    "Chores",
                    systemImage: "checklist",
                    description: Text("Manage family chores here.")
                )
                .tabItem { Label("Chores", systemImage: "checklist") }

                ContentUnavailableView(
                    "Rewards",
                    systemImage: "gift",
                    description: Text("Manage family rewards here.")
                )
                .tabItem { Label("Rewards", systemImage: "gift") }

                ContentUnavailableView(
                    "Settings",
                    systemImage: "gear",
                    description: Text("Manage your account and family settings.")
                )
                .tabItem { Label("Settings", systemImage: "gear") }

            } else {
                // ----- Child Tabs -----
                ContentUnavailableView(
                    "My Chores",
                    systemImage: "checkmark.circle",
                    description: Text("Your assigned chores will appear here.")
                )
                .tabItem { Label("My Chores", systemImage: "checkmark.circle") }

                ContentUnavailableView(
                    "My Rewards",
                    systemImage: "gift.fill",
                    description: Text("View and redeem rewards.")
                )
                .tabItem { Label("My Rewards", systemImage: "gift.fill") }

                ContentUnavailableView(
                    "Profile",
                    systemImage: "person.crop.circle",
                    description: Text("View your profile and progress.")
                )
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
        }
    }
}
