import SwiftUI

@main
struct AllowanceAlleyApp: App {
    // If you already create FamilyStore elsewhere, use that instead.
    // Try FamilyStore() first; if it fails to compile, fall back to FamilyStore.demo().
    @StateObject private var familyStore = FamilyStore() // or FamilyStore.demo()
    @StateObject private var ledger      = AALedgerStore()
    @StateObject private var choreStore  = AAChoreStore()
    @StateObject private var rewardStore = AARewardStore()

    var body: some Scene {
        WindowGroup {
            ContentViewBRD()
                .environmentObject(familyStore)
                .environmentObject(ledger)
                .environmentObject(choreStore)
                .environmentObject(rewardStore)
        }
    }
}
