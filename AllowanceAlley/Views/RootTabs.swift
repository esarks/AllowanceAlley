import SwiftUI

/// Optional root to wire the new tabs into your app quickly.
struct RootTabs: View {
    private let familyId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let childId = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!

    var body: some View {
        TabView {
            // Placeholder for your existing chore screen
            ContentUnavailableView("Chores", systemImage: "checklist", description: Text("Wire your existing screen here."))
                .tabItem {
                    Label("Chores", systemImage: "checklist")
                }
            RewardsListView(familyId: familyId, childId: childId)
                .tabItem {
                    Label("Rewards", systemImage: "gift")
                }
            ApprovalsInboxView(familyId: familyId)
                .tabItem {
                    Label("Approvals", systemImage: "inbox")
                }
            RewardCatalogView(familyId: familyId)
                .tabItem {
                    Label("Catalog", systemImage: "archivebox")
                }
        }
    }
}

#Preview {
    RootTabs()
}
