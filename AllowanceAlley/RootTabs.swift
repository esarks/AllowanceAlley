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
            if role.lowercased() == "parent" {
                ContentUnavailableView("Approvals", systemImage: "inbox", description: Text("Parent inbox"))
                    .tabItem { Label("Approvals", systemImage: "inbox") }
                ContentUnavailableView("Catalog", systemImage: "archivebox", description: Text("Reward catalog"))
                    .tabItem { Label("Catalog", systemImage: "archivebox") }
                ContentUnavailableView("Chores", systemImage: "checklist", description: Text("Manage chores"))
                    .tabItem { Label("Chores", systemImage: "checklist") }
            } else {
                ContentUnavailableView("My Chores", systemImage: "checklist", description: Text("Assigned chores"))
                    .tabItem { Label("My Chores", systemImage: "checklist") }
                ContentUnavailableView("Rewards", systemImage: "gift", description: Text("Browse rewards"))
                    .tabItem { Label("Rewards", systemImage: "gift") }
                ContentUnavailableView("Points", systemImage: "target", description: Text("Points ledger"))
                    .tabItem { Label("Points", systemImage: "target") }
            }
        }
    }
}
