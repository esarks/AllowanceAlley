# AllowanceAlley — Working App Drop‑In

This pack gives you a working post‑login flow with role‑aware tabs and a first‑run setup screen.

## What’s included
- `AppRouterView.swift` — entry router: checks session, resolves role/family, routes to tabs or setup.
- `RoleResolver.swift` — determines **parent** (owns a family) vs **child** (is a family member) using your tables.
- `RootTabs.swift` — parent/child `TabView` containers.
- `SetupFamilyView.swift` — shown only when a signed‑in user has **no** family; creates one and routes to tabs.
- Placeholder feature screens you can wire up later:
  - `DashboardView.swift`, `ChoresView.swift`, `RewardsView.swift`
- `SupabaseService.swift` — tiny convenience wrapper (optional) so calls are in one place.
- `SQL/seed_family.sql` — optional convenience script to create a starter family for the logged‑in user.

## How to integrate
1) In your `@main` app file (e.g. `AllowanceAlleyApp.swift`), set the root to the router:
   ```swift
   var body: some Scene {
     WindowGroup { AppRouterView() }
   }
   ```
2) Drag the **AllowanceAlley/** folder from this zip into your Xcode project. In the add dialog:
   - Check **Copy items if needed**.
   - Ensure **Target Membership** is checked for your app target on every file.
3) Build & run. You will:
   - Land in **RootTabs** if your signed‑in user already owns or belongs to a family.
   - See **SetupFamilyView** if they don’t — tap **Create Family** once.

## Notes
- Code assumes you already have a `SupabaseManager.shared.client` configured.
- Built for newer Supabase Swift where `auth.session` is **async** and `session.user.id` is a **UUID**.
- If your SDK differs slightly, tweak the `AppRouterView.check()` and `RoleResolver.resolve()` to match (both are compact and easy to adjust).
