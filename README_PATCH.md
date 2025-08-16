# AllowanceAlley — Wiring Patch v1

This patch connects your existing domain (FamilyStore, RewardsViewModel)
to the visible tabs so Chores/Rewards/Profile show real content.

## Files in this patch
- Config/AllowanceAlleyApp.swift  ← injects FamilyStore + Rewards VM at app root
- Config/ContentView.swift        ← TabView wired to real screens
- Views/ChoresTabView.swift       ← passes `familyId` + `childId` to ChoresView
- Views/ProfileTabView.swift      ← simple profile summary

## Install (5 steps, 60 seconds)
1) In Xcode, **delete** your existing `AllowanceAlleyApp.swift` and `ContentView.swift`
   from the project (choose *Remove Reference* if you want to keep originals on disk).
2) Drag the `Config/` and `Views/` folders from this patch into Xcode's project navigator.
   When prompted, select your app target in **Add to targets**.
3) For each added file, open **File Inspector → Target Membership** and be sure
   your app target is checked.
4) Product → **Clean Build Folder** (⇧⌘K). Delete the app from the Simulator.
5) Run.

## Notes
- `ChoresTabView` calls `ChoresView(familyId: store.familyId, childId: firstChild.id)`.
  If your `FamilyStore` uses `id` (not `familyId`), change that one line to `store.id`.
- Rewards screens expect a `RewardsViewModel` via `@EnvironmentObject`. If your views
  still create the VM locally (`@StateObject`), switch them to `@EnvironmentObject`.
- Nothing here touches Supabase; it works with your existing demo data.
