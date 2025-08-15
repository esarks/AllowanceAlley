AllowanceAlley – One-Click Compile Fix (Drop-in Pack)
=====================================================
Why this exists
---------------
Your build errors came from duplicate type declarations spread across multiple files:
`UserRole`, `RoleContext`, and `RouterStage`/`AppStage` were each defined in more than one file
(e.g., RouterStage.swift, AppRouterView.swift, AppRouter, ProfileView.swift, etc.).
Swift then reported “Invalid redeclaration”, “ambiguous for type lookup”, and 
`does not conform to Equatable` symptoms.

What this pack does
-------------------
1) **Defines all shared types in one place** (AppTypes.swift).
2) **Routes with a single main router view** (MainRouterView.swift).
3) **Provides minimal, compile-safe stubs** for RoleResolver, SupabaseService,
   RootTabsView, SetupFamilyView, and ProfileView.
4) **Removes the need for RouterStage.swift** (the stage enum lives in AppTypes.swift).

How to apply (2 minutes)
------------------------
A) In Xcode *delete* (move to trash) any files in your project that define these types:
   - RouterStage.swift (or any file that defines `RouterStage`)
   - Any other file that defines `UserRole` or `RoleContext`
   - The old `AppRouterView.swift` if you had a duplicate router view
   - Extra copies of SetupFamilyView/ProfileView/RootTabsView if they duplicate these names

   Tip: In the left navigator, use the search box to find "enum RouterStage", "enum UserRole",
   and "struct RoleContext" and delete duplicates. Keep the files from THIS pack.

B) Add the 7 files from this zip to your app target (recommended group: "AllowanceAlley"):
   - AppTypes.swift
   - SupabaseService.swift
   - RoleResolver.swift
   - MainRouterView.swift
   - RootTabsView.swift
   - SetupFamilyView.swift
   - ProfileView.swift

C) Set your app’s root view to `MainRouterView()` (e.g., in AllowanceAlleyApp.swift).

   Example AllowanceAlleyApp.swift:
   --------------------------------
   import SwiftUI

   @main
   struct AllowanceAlleyApp: App {
       @StateObject private var client = SupabaseService()

       var body: some Scene {
           WindowGroup {
               MainRouterView()
                   .environmentObject(client)
           }
       }
   }

D) Build & run.

Notes
-----
- `SupabaseService` here is a minimal stub with a simple async `session()`.
  Replace with your real Supabase auth/session implementation when ready.
- `RoleResolver` currently returns a demo RoleContext for a parent; if you want to
  surface a "needs setup" screen, set `demoHasFamily = false` in RoleResolver.resolve().

If you still see any "invalid redeclaration" errors after adding these files,
you still have an old duplicate file hanging around. Delete it from the project (and disk).
