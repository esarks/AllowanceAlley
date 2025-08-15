AllowanceAlley – Compile Fix Pack (v2)
======================================

What this does
--------------
- Defines ONE set of shared types (UserRole, RoleContext, AppStage).
- Provides ONE router (MainRouterView) and simple views (RootTabsView, SetupFamilyView, ProfileView).
- Includes a minimal SupabaseService stub and a RoleResolver stub.

How to apply (safest)
---------------------
1) Close Xcode.
2) In Terminal, cd into your repo root and run:
     bash apply_fix.sh
   The script will:
     • Search for duplicate type/view declarations.
     • Backup any conflicting files into ./AA_Fix_Backup/
     • Copy these fixed files into your repo root.
3) Reopen Xcode, ensure your @main App uses MainRouterView() with
     .environmentObject(SupabaseService())
4) Product → Clean Build Folder, then Build.

Manual (if you don't want to run the script)
--------------------------------------------
- Add these 7 .swift files to your app target.
- DELETE or remove from target any files that also define:
    - enum RouterStage / enum AppStage
    - enum UserRole
    - struct RoleContext
    - struct RootTabsView
    - struct SetupFamilyView
    - struct ProfileView
    - struct AppRouterView / MainRouterView (keep only one)
- Set AllowanceAlleyApp root to MainRouterView().
