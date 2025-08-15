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
                DashboardView(familyId: familyId)
                    .tabItem { Label("Dashboard", systemImage: "house") }

                ChoresView(familyId: familyId)
                    .tabItem { Label("Chores", systemImage: "checklist") }

                RewardsView(familyId: familyId)
                    .tabItem { Label("Rewards", systemImage: "gift") }
            } else {
                ChoresView(familyId: familyId, childId: childUserId)
                    .tabItem { Label("My Chores", systemImage: "checkmark.circle") }

                RewardsView(familyId: familyId, childId: childUserId)
                    .tabItem { Label("Rewards", systemImage: "gift.fill") }
            }
        }
    }
}
