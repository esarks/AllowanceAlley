import SwiftUI

/// Entry for the Rewards tab. Shows a list of rewards and gives quick access
/// to the Catalog (for parents to add rewards) and Approvals inbox.
struct RewardsHomeView: View {
    @EnvironmentObject var viewModel: RewardsViewModel

    var body: some View {
        NavigationStack {
            // This view already exists in the repo and reads from RewardsViewModel
            RewardsListView()
                .navigationTitle("Rewards")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        NavigationLink {
                            RewardCatalogView()
                        } label: {
                            Label("Catalog", systemImage: "plus.circle")
                        }

                        NavigationLink {
                            ApprovalsInboxView()
                        } label: {
                            Label("Approvals", systemImage: "tray.full")
                        }
                    }
                }
        }
    }
}
