# AllowanceAlley — Role‑Based Routing (Drop‑In)

This package makes your app switch to the correct navigation **immediately after login**,
based on whether the current user is the **family owner (parent)** or a **member (child)**.

It assumes your schema/policies like you shared:
- Parents are `families.owner_id`.
- Children are rows in `family_members` with `user_id` = the child’s auth user id.

## What’s included
- `SQL/schema_helpers.sql` (optional): view + RPC examples (not required for the Swift code to work).
- `AllowanceAlley/RoleResolver.swift`: figures out `(familyId, role)` by querying your existing tables with RLS.
- `AllowanceAlley/AppRouter.swift`: small state machine to show Login vs. RootTabs.
- `AllowanceAlley/RootTabs.swift`: simple tab bar that differs for Parent vs Child.
- `AllowanceAlley/LoginPlaceholderView.swift`: placeholder shown if the user is not authenticated.

## Install (2 steps)
1) Drag the **AllowanceAlley/** folder into your Xcode project (Copy items if needed).
2) Use `AppRouterView()` as your app’s entry view (e.g., in `@main` app or your `ContentView`).

That’s it — after you sign in, it will fetch the family + role and push you into the correct tabs.

### Optional: Run the SQL helpers
Open Supabase → SQL Editor and run `SQL/schema_helpers.sql` if you want RPCs.
The Swift in this pack does **not** require them.

## Notes
- The code expects a shared Supabase client at `SupabaseManager.shared.client`.
  If yours is named differently, adjust the two places marked `// TODO: point to your client`.
- Child tabs pass the child’s **auth user id** as `childId`. If you model children without logins,
  you can tweak `RoleResolver` to look up a `family_members.id` for a selected child instead.
