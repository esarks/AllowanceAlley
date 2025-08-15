#!/usr/bin/env bash
set -euo pipefail

echo "== AllowanceAlley Purge & Fix =="
BACKUP="AA_PurgeBackup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"

# Candidate declarations to purge (moved to backup)
declare -a NAMES=(
  "enum[[:space:]]+RouterStage"
  "enum[[:space:]]+UserRole"
  "struct[[:space:]]+RoleContext"
  "struct[[:space:]]+RootTabsView"
  "struct[[:space:]]+SetupFamilyView"
  "struct[[:space:]]+ProfileView"
  "struct[[:space:]]+AppRouterView"
  "struct[[:space:]]+MainRouterView"
)

echo "-- scanning for duplicate declarations..."
FOUND=()
for pat in "${NAMES[@]}"; do
  while IFS= read -r file; do
    # don't back up the new files from this pack
    case "$file" in
      *AppTypes.swift|*SupabaseService.swift|*RoleResolver.swift|*MainRouterView.swift|*RootTabsView.swift|*SetupFamilyView.swift|*ProfileView.swift)
        continue
        ;;
    esac
    FOUND+=("$file")
  done < <(grep -RIl --exclude-dir="$BACKUP" -e "$pat" . || true)
done

if [ ${#FOUND[@]} -gt 0 ]; then
  echo "-- backing up old/duplicate files to $BACKUP"
  for f in "${FOUND[@]}"; do
    [ -f "$f" ] || continue
    mkdir -p "$BACKUP/$(dirname "$f")"
    mv "$f" "$BACKUP/$(dirname "$f")/"
    echo "moved: $f"
  done
else
  echo "-- no duplicates found (or already cleaned)"
fi

echo "-- installing canonical files"
cp -f AppTypes.swift SupabaseService.swift RoleResolver.swift MainRouterView.swift RootTabsView.swift SetupFamilyView.swift ProfileView.swift ./

echo "Done. Open Xcode, clean build folder, and build."
