
# AA Additive Features (Non‑Breaking)

This pack adds a local points ledger and two optional V2 screens.
It **does not** modify existing files. Drag these into Xcode and check your app target.

## Files
- `AALedgerStore.swift` — persisted earn/redeem ledger (Documents/aa_ledger.json)
- `AARewardsCatalog.swift` — simple demo rewards
- `ChoresV2View.swift` — chores that earn points
- `RewardsV2View.swift` — redeem points for rewards

## Inject the store (required once)

```swift
// AllowanceAlleyApp.swift
@main
struct AllowanceAlleyApp: App {
    @StateObject private var ledger = AALedgerStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ledger) // add this
        }
    }
}
```

## Try the screens (optional tabs)
```swift
TabView {
  // your existing tabs…
  ChoresV2View().tabItem { Label("Chores 2", systemImage: "checkmark.circle") }
  RewardsV2View().tabItem { Label("Rewards 2", systemImage: "gift") }
}
```

Later, replace the demo `childId` with your selected child id from your store.
