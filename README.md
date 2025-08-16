
# Additive Tabs (wired to FamilyStore)

Drop-in, no-breaking features:
- `AALedgerStore.swift` (persisted points)
- `ChoresV2View.swift` & `RewardsV2View.swift` (auto-pick first child from `FamilyStore`)
- `ChoresTabView.swift` & `RewardsTabView.swift` (optional adapters)
- `AARewardsCatalog.swift` (demo rewards)

## Inject the store(s)

```swift
@main
struct AllowanceAlleyApp: App {
  @StateObject private var ledger = AALedgerStore()
  @StateObject private var familyStore = FamilyStore.demo() // or your real one

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(familyStore)
        .environmentObject(ledger)
    }
  }
}
```

## Use as extra tabs

```swift
TabView {
  // existing tabs...
  ChoresV2View().tabItem { Label("Chores", systemImage: "checkmark.circle") }
  RewardsV2View().tabItem { Label("Rewards", systemImage: "gift") }
}
```

If no child exists, the screens show a friendly "No child yet" state instead of a crash.
