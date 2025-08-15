#!/usr/bin/env bash
set -euo pipefail

echo "AllowanceAlley Compile Fix Pack (v2)"
echo "This will back up duplicates and copy clean files into your repo."
echo

BACKUP_DIR="AA_Fix_Backup"
mkdir -p "$BACKUP_DIR"

# Patterns to look for
declare -a PATTERNS=(
  "enum[[:space:]]+RouterStage"
  "enum[[:space:]]+AppStage"
  "enum[[:space:]]+UserRole"
  "struct[[:space:]]+RoleContext"
  "struct[[:space:]]+RootTabsView"
  "struct[[:space:]]+SetupFamilyView"
  "struct[[:space:]]+ProfileView"
  "struct[[:space:]]+AppRouterView"
  "struct[[:space:]]+MainRouterView"
)

echo "Scanning for duplicate declarations..."
FOUND_FILES=()
for pat in "${PATTERNS[@]}"; do
  while IFS= read -r -d '' f; do
    # skip our fix files themselves if running from repo root
    case "$f" in
      *AppTypes.swift|*SupabaseService.swift|*RoleResolver.swift|*MainRouterView.swift|*RootTabsView.swift|*SetupFamilyView.swift|*ProfileView.swift)
        continue
        ;;
    esac
    FOUND_FILES+=("$f")
  done < <(grep -RIl --exclude-dir="$BACKUP_DIR" -e "$pat" . | xargs -0 -n1 printf "%s\0" 2>/dev/null || true)
done

if [ ${#FOUND_FILES[@]} -gt 0 ]; then
  echo "Backing up possible duplicates:"
  for f in "${FOUND_FILES[@]}"; do
    echo "  -> $f"
    # Preserve path inside backup dir
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    mv "$f" "$BACKUP_DIR/$(dirname "$f")"/ 2>/dev/null || true
  done
else
  echo "No duplicates found (or already cleaned)."
fi

echo
echo "Copying fixed files into project root..."
cp -f "AppTypes.swift" "SupabaseService.swift" "RoleResolver.swift" "MainRouterView.swift" "RootTabsView.swift" "SetupFamilyView.swift" "ProfileView.swift" "./"

echo "Done."
echo "Open Xcode, set the app root to MainRouterView().environmentObject(SupabaseService()),"
echo "then Clean Build Folder and Build."
