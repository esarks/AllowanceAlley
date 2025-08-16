# Option B — Add Rescue as a Tab (no @main changes)
1) Drag ONLY `RescueRootView.swift` from `OptionB_AddRescueTab` into Xcode.
2) Open your TabView (likely `ContentView.swift`) and add:
   ```swift
   RescueRootView()
     .tabItem { Label("Rescue", systemImage: "lifepreserver") }
   ```
3) Clean build (⇧⌘K) → Run.

You’ll see a **Rescue** tab with working Dashboard/Chores/Rewards that do NOT depend on any environment objects.
If you still don’t see it, your app is launching a different target/scheme.
