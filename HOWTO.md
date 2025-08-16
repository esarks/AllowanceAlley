
# Tabs Swap Pack (Non-breaking)

1) Drag all files into Xcode; tick **Target Membership → AllowanceAlley**.
2) Ensure these are injected once at app entry (AllowanceAlleyApp.swift):
   ```swift
   @StateObject private var familyStore = FamilyStore.demo() // or real
   @StateObject private var ledger = AALedgerStore()
   ContentView() // or ContentViewV2()
     .environmentObject(familyStore)
     .environmentObject(ledger)
   ```
3) To try the functional tabs without changing your existing `ContentView`:
   - In `AllowanceAlleyApp`, temporarily use `ContentViewV2()` as the root.
   - Or copy the tabs from `ContentViewV2` into your existing `ContentView`.

`ChoresV2View` awards points; `RewardsV2View` redeems points. Both pick the first child from `FamilyStore` or show a friendly empty state.
