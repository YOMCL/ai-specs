#!/usr/bin/env bash
# update-ai-specs.sh — Push ai-specs framework updates to a target project
#
# This script runs FROM the ai-specs repo and targets an external project.
# The ai-specs repo (where this script lives) is always the upstream source.
#
# Usage:
#   ./update-ai-specs.sh <project-path>
#
# Examples:
#   ./update-ai-specs.sh ../yom-api
#   ./update-ai-specs.sh /home/user/projects/my-app
#
# What it does:
#   1. Reads .manifest.json to classify files
#   2. Copies "safe_to_overwrite" files directly into the project
#   3. Generates diffs for "adapted" files in <project>/.update-review/
#   4. Recreates missing symlinks in the project
#   5. Prints a summary
#
# After running, open the target project and use /update-ai-specs to
# AI-merge the adapted file diffs.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Upstream = the directory where this script lives (ai-specs repo)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM_DIR="$SCRIPT_DIR"
MANIFEST="$UPSTREAM_DIR/ai-specs/.manifest.json"

# --- Helpers ---

log_info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
  echo "Usage: $0 <project-path>"
  echo ""
  echo "  project-path  Path to the target project that has adopted ai-specs"
  echo ""
  echo "This script runs from the ai-specs repo (upstream) and pushes updates"
  echo "into the target project, respecting adapted vs safe-to-overwrite files."
  exit 1
}

require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    log_err "Required command '$1' not found. Please install it."
    exit 1
  fi
}

# Read a JSON array from the manifest using python (avoids jq dependency)
read_manifest_array() {
  local path="$1"
  python3 -c "
import json, sys
with open('$MANIFEST') as f:
    data = json.load(f)
keys = '$path'.split('.')
node = data
for k in keys:
    node = node[k]
for item in node:
    print(item)
"
}

# --- Validations ---

if [[ $# -lt 1 ]]; then
  usage
fi

PROJECT_DIR="$(cd "$1" && pwd)"
REVIEW_DIR="$PROJECT_DIR/.update-review"

require_cmd python3
require_cmd diff

if [[ ! -f "$MANIFEST" ]]; then
  log_err "Manifest not found at $MANIFEST. Is this the ai-specs repo?"
  exit 1
fi

if [[ ! -d "$PROJECT_DIR/ai-specs" ]]; then
  log_err "No ai-specs/ directory found in $PROJECT_DIR. Has this project adopted ai-specs?"
  exit 1
fi

log_info "Upstream (ai-specs):  $UPSTREAM_DIR"
log_info "Target project:       $PROJECT_DIR"
echo ""

# --- Prepare review directory ---

rm -rf "$REVIEW_DIR"
mkdir -p "$REVIEW_DIR"

# --- Counters ---

UPDATED=0
SKIPPED=0
DIFFS_GENERATED=0
SYMLINKS_FIXED=0
MISSING_UPSTREAM=0

# --- Phase 1: Copy safe_to_overwrite files ---

log_info "Phase 1: Updating safe_to_overwrite files..."

while IFS= read -r file; do
  upstream_file="$UPSTREAM_DIR/$file"
  project_file="$PROJECT_DIR/$file"

  if [[ ! -f "$upstream_file" ]]; then
    log_warn "Not in upstream: $file (skipping)"
    MISSING_UPSTREAM=$((MISSING_UPSTREAM + 1))
    continue
  fi

  if [[ ! -f "$project_file" ]]; then
    # New file from upstream — copy it
    mkdir -p "$(dirname "$project_file")"
    cp "$upstream_file" "$project_file"
    log_ok "NEW  $file"
    UPDATED=$((UPDATED + 1))
    continue
  fi

  # Compare and overwrite if different
  if ! diff -q "$project_file" "$upstream_file" &>/dev/null; then
    cp "$upstream_file" "$project_file"
    log_ok "UPDATED  $file"
    UPDATED=$((UPDATED + 1))
  else
    SKIPPED=$((SKIPPED + 1))
  fi
done < <(read_manifest_array "categories.safe_to_overwrite.files")

# --- Phase 2: Generate diffs for adapted files ---

log_info "Phase 2: Generating diffs for adapted files..."

while IFS= read -r file; do
  upstream_file="$UPSTREAM_DIR/$file"
  project_file="$PROJECT_DIR/$file"

  if [[ ! -f "$upstream_file" ]]; then
    log_warn "Not in upstream: $file (skipping)"
    MISSING_UPSTREAM=$((MISSING_UPSTREAM + 1))
    continue
  fi

  if [[ ! -f "$project_file" ]]; then
    # File doesn't exist in project — copy upstream version as starting point
    mkdir -p "$(dirname "$project_file")"
    cp "$upstream_file" "$project_file"
    log_ok "NEW (adapted, needs customization)  $file"
    UPDATED=$((UPDATED + 1))
    continue
  fi

  # Generate diff if files differ
  if ! diff -q "$project_file" "$upstream_file" &>/dev/null; then
    diff_file="$REVIEW_DIR/$(echo "$file" | tr '/' '_').diff"

    # Generate unified diff: project (current) vs upstream (proposed)
    diff -u "$project_file" "$upstream_file" \
      --label "project: $file" \
      --label "upstream: $file" \
      > "$diff_file" || true  # diff returns 1 when files differ

    # Also copy the upstream version for reference
    upstream_copy="$REVIEW_DIR/$(echo "$file" | tr '/' '_').upstream"
    cp "$upstream_file" "$upstream_copy"

    log_warn "DIFF  $file -> .update-review/$(echo "$file" | tr '/' '_').diff"
    DIFFS_GENERATED=$((DIFFS_GENERATED + 1))
  else
    SKIPPED=$((SKIPPED + 1))
  fi
done < <(read_manifest_array "categories.adapted.files")

# --- Phase 3: Fix missing symlinks ---

log_info "Phase 3: Checking symlinks..."

while IFS= read -r symlink; do
  project_link="$PROJECT_DIR/$symlink"

  if [[ ! -e "$project_link" ]]; then
    # Determine the symlink target from upstream
    upstream_link="$UPSTREAM_DIR/$symlink"
    if [[ -L "$upstream_link" ]]; then
      target="$(readlink "$upstream_link")"
      mkdir -p "$(dirname "$project_link")"
      ln -s "$target" "$project_link"
      log_ok "SYMLINK  $symlink -> $target"
      SYMLINKS_FIXED=$((SYMLINKS_FIXED + 1))
    elif [[ -f "$upstream_link" ]]; then
      # Upstream has a real file, not a symlink — copy it
      mkdir -p "$(dirname "$project_link")"
      cp "$upstream_link" "$project_link"
      log_ok "COPIED (expected symlink)  $symlink"
      SYMLINKS_FIXED=$((SYMLINKS_FIXED + 1))
    else
      log_warn "Missing in upstream: $symlink"
    fi
  fi
done < <(read_manifest_array "categories.symlinks.files")

# --- Phase 4: Detect new upstream files not in manifest ---

log_info "Phase 4: Checking for new upstream files not in manifest..."

NEW_FILES=()
while IFS= read -r upstream_file; do
  # Strip upstream dir prefix to get relative path
  rel_path="${upstream_file#$UPSTREAM_DIR/}"

  # Skip upstream-only files (not distributed to projects)
  [[ "$rel_path" == .git/* ]] && continue
  [[ "$rel_path" == *.DS_Store ]] && continue
  [[ "$rel_path" == ai-specs/changes/* ]] && continue
  [[ "$rel_path" == update-ai-specs.sh ]] && continue
  [[ "$rel_path" == .gitignore ]] && continue
  [[ "$rel_path" == .claude/settings.local.json ]] && continue
  [[ "$rel_path" == .claude/memory* ]] && continue

  # Check if this file is in any manifest category
  in_manifest=false
  for category in safe_to_overwrite adapted symlinks; do
    if read_manifest_array "categories.$category.files" 2>/dev/null | grep -qxF "$rel_path"; then
      in_manifest=true
      break
    fi
  done

  if [[ "$in_manifest" == false ]]; then
    NEW_FILES+=("$rel_path")
  fi
done < <(find "$UPSTREAM_DIR" -type f -not -path "*/.git/*" | sort)

if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
  log_warn "New upstream files not in manifest:"
  for f in "${NEW_FILES[@]}"; do
    echo "  + $f"
  done
  echo ""
  log_warn "Add these to ai-specs/.manifest.json in the upstream repo."
fi

# --- Summary ---

echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ai-specs Update Summary${NC}"
echo -e "${CYAN}  Target: ${PROJECT_DIR}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "  Files updated (overwritten):  ${GREEN}$UPDATED${NC}"
echo -e "  Files unchanged (skipped):    $SKIPPED"
echo -e "  Diffs to review:              ${YELLOW}$DIFFS_GENERATED${NC}"
echo -e "  Symlinks fixed:               $SYMLINKS_FIXED"
echo -e "  Missing from upstream:        $MISSING_UPSTREAM"
echo -e "  New upstream files:           ${#NEW_FILES[@]}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"

if [[ $DIFFS_GENERATED -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}Adapted files have upstream changes. Review diffs in:${NC}"
  echo -e "  $REVIEW_DIR/"
  echo ""
  echo -e "Open the target project and run ${CYAN}/update-ai-specs${NC} to AI-merge the pending diffs."
fi

# Clean up empty review dir
if [[ -d "$REVIEW_DIR" ]] && [[ -z "$(ls -A "$REVIEW_DIR")" ]]; then
  rmdir "$REVIEW_DIR"
fi

exit 0
