import SwiftUI

@main
struct AllowanceAlleyApp: App {
    // Provide the store app-wide (use .live() when ready)
    @StateObject private var familyStore = FamilyStore.demo()

    // Provide a single RewardsViewModel to all rewards screens
    @StateObject private var rewardsVM: RewardsViewModel = {
        #if canImport(Foundation)
        // If you have DI, use it; else fall back to in-memory demo
        if let make = RewardsDI.makeViewModel {
            return make()
        } else {
            return RewardsViewModel(repository: InMemoryRewardsRepository.demo())
        }
        #else
        return RewardsViewModel(repository: InMemoryRewardsRepository.demo())
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyStore)
                .environmentObject(rewardsVM)
        }
    }
}
