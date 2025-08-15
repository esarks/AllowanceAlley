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
                ApprovalsInboxView(familyId: familyId)
                    .tabItem { Label("Approvals", systemImage: "inbox") }

                RewardCatalogView(familyId: familyId)
                    .tabItem { Label("Catalog", systemImage: "archivebox") }

                ContentUnavailableView("Chores", systemImage: "checklist", description: Text("Parent chore management coming next."))
                    .tabItem { Label("Chores", systemImage: "checklist") }
            } else {
                if let childUserId {
                    RewardsListView(familyId: familyId, childId: childUserId)
                        .tabItem { Label("Rewards", systemImage: "gift") }
                } else {
                    ContentUnavailableView("Rewards", systemImage: "gift", description: Text("No child id detected."))
                        .tabItem { Label("Rewards", systemImage: "gift") }
                }

                ContentUnavailableView("My Chores", systemImage: "checkmark.circle", description: Text("Assigned chores list coming next."))
                    .tabItem { Label("Chores", systemImage: "checkmark.circle") }
            }
        }
    }
}
