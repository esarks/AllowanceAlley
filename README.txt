
# Rescue Pack v2 (Loud mode)
- Option A: Replace @main. You'll see an orange **RESCUE MODE** banner.
- Option B: Add a **Rescue** tab (or use the provided `ContentView_RescueShim.swift`).

If you don't see the banner or the Rescue tab after adding:
- You’re on the wrong scheme/target OR
- The file(s) are not in your target membership (File > Inspector > Target Membership).
- Old `AllowanceAlleyApp.swift` is still compiling; delete it from the project.
