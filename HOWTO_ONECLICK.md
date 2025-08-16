# One‑Click BRD Features (No Breaking Changes)

## 1) Drag all files into Xcode
Tick **Target Membership → AllowanceAlley** for each.

## 2) Use the BRD tab container as your root (visible change)
In `AllowanceAlleyApp.swift`:
```swift
@StateObject private var familyStore = FamilyStore.demo() // or your real store
@StateObject private var ledger      = AALedgerStore()
@StateObject private var choreStore  = AAChoreStore()
@StateObject private var rewardStore = AARewardStore()

WindowGroup {
  ContentViewBRD()
    .environmentObject(familyStore)
    .environmentObject(ledger)
    .environmentObject(choreStore)
    .environmentObject(rewardStore)
}
```

## 3) Clean Build Folder → Run
You’ll see Dashboard, Chores, Rewards, and Admin (catalog + approvals).
