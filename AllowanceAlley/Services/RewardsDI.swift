import Foundation

enum RewardsDI {
    // Flip to true when Supabase repo is implemented.
    static let useSupabase = false

    @MainActor
    static func makeRepo() -> any RewardsRepository {
        if useSupabase {
            return SupabaseRewardsRepository()
        } else {
            return InMemoryRewardsRepository()
        }
    }
}
