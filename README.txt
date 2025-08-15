RUN THIS:
  1) Quit Xcode.
  2) In Terminal, cd to your repo root and run:
       bash purge_and_apply.sh
  3) Reopen Xcode, remove any RED references the backup created, set root to:
       MainRouterView().environmentObject(SupabaseService())
  4) Clean Build Folder, then Build.

The script backs up any files that declare the problematic types (RouterStage, UserRole, RoleContext)
and view names (RootTabsView, SetupFamilyView, ProfileView, AppRouterView/MainRouterView), then installs
the canonical files that compile cleanly.
