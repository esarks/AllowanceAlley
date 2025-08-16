# BRD Feature Pack (v2)

1. Drag all files into Xcode and tick Target Membership.
2. In AllowanceAlleyApp.swift inject once:
   @StateObject private var familyStore = FamilyStore.demo() // or your real store
   @StateObject private var ledger      = AALedgerStore()
   @StateObject private var choreStore  = AAChoreStore()
   @StateObject private var rewardStore = AARewardStore()

   WindowGroup {
     ContentViewBRD() // or forward your existing tabs to AAChoreListView/AARewardsRedeemView
       .environmentObject(familyStore)
       .environmentObject(ledger)
       .environmentObject(choreStore)
       .environmentObject(rewardStore)
   }

3. Clean Build Folder → Run.
