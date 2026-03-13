#!/usr/bin/env bash
# update-ai-specs.sh — Update ai-specs framework from upstream source
#
# Usage:
#   ./update-ai-specs.sh <upstream-path>
#   ./update-ai-specs.sh https://github.com/YOMCL/ai-specs.git
#   ./update-ai-specs.sh https://github.com/YOMCL/ai-specs.git main
#
# What it does:
#   1. Reads .manifest.json to classify files
#   2. Copies "safe_to_overwrite" files directly from upstream
#   3. Generates diffs for "adapted" files in .update-review/
#   4. Recreates missing symlinks
#   5. Prints a summary
#
# After running, use /update-ai-specs to AI-merge the adapted file diffs.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

MANIFEST="ai-specs/.manifest.json"
REVIEW_DIR=".update-review"
UPSTREAM_SOURCE="$1"
UPSTREAM_BRANCH="${2:-production}"

# --- Helpers ---

log_info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
  echo "Usage: $0 <upstream-path-or-git-url> [branch]"
  echo ""
  echo "  upstream-path-or-git-url  Local path or git URL to the ai-specs upstream repo"
  echo "  branch                    Git branch to use (default: production)"
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

require_cmd python3
require_cmd git
require_cmd diff

if [[ ! -f "$MANIFEST" ]]; then
  log_err "Manifest not found at $MANIFEST. Are you in the project root?"
  exit 1
fi

# --- Resolve upstream to a local path ---

UPSTREAM_DIR=""
CLEANUP_UPSTREAM=false

if [[ -d "$UPSTREAM_SOURCE" ]]; then
  # Local path
  UPSTREAM_DIR="$(cd "$UPSTREAM_SOURCE" && pwd)"
  log_info "Using local upstream: $UPSTREAM_DIR"
elif [[ "$UPSTREAM_SOURCE" == http* || "$UPSTREAM_SOURCE" == git@* ]]; then
  # Git URL — clone to temp dir
  UPSTREAM_DIR="$(mktemp -d)"
  CLEANUP_UPSTREAM=true
  log_info "Cloning upstream from $UPSTREAM_SOURCE (branch: $UPSTREAM_BRANCH)..."
  git clone --depth 1 --branch "$UPSTREAM_BRANCH" "$UPSTREAM_SOURCE" "$UPSTREAM_DIR" 2>/dev/null
  log_ok "Cloned to temp directory"
else
  log_err "Upstream source '$UPSTREAM_SOURCE' is neither a valid directory nor a git URL."
  exit 1
fi

cleanup() {
  if [[ "$CLEANUP_UPSTREAM" == true && -d "$UPSTREAM_DIR" ]]; then
    rm -rf "$UPSTREAM_DIR"
  fi
}
trap cleanup EXIT

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

  if [[ ! -f "$upstream_file" ]]; then
    log_warn "Not in upstream: $file (skipping)"
    MISSING_UPSTREAM=$((MISSING_UPSTREAM + 1))
    continue
  fi

  if [[ ! -f "$file" ]]; then
    # New file from upstream — copy it
    mkdir -p "$(dirname "$file")"
    cp "$upstream_file" "$file"
    log_ok "NEW  $file"
    UPDATED=$((UPDATED + 1))
    continue
  fi

  # Compare and overwrite if different
  if ! diff -q "$file" "$upstream_file" &>/dev/null; then
    cp "$upstream_file" "$file"
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

  if [[ ! -f "$upstream_file" ]]; then
    log_warn "Not in upstream: $file (skipping)"
    MISSING_UPSTREAM=$((MISSING_UPSTREAM + 1))
    continue
  fi

  if [[ ! -f "$file" ]]; then
    # File doesn't exist locally — copy upstream version as starting point
    mkdir -p "$(dirname "$file")"
    cp "$upstream_file" "$file"
    log_ok "NEW (adapted, needs customization)  $file"
    UPDATED=$((UPDATED + 1))
    continue
  fi

  # Generate diff if files differ
  if ! diff -q "$file" "$upstream_file" &>/dev/null; then
    diff_file="$REVIEW_DIR/$(echo "$file" | tr '/' '_').diff"

    # Generate unified diff: local (current) vs upstream (proposed)
    diff -u "$file" "$upstream_file" \
      --label "local: $file" \
      --label "upstream: $file" \
      > "$diff_file" || true  # diff returns 1 when files differ

    # Also copy the upstream version for reference
    upstream_copy="$REVIEW_DIR/$(echo "$file" | tr '/' '_').upstream"
    cp "$upstream_file" "$upstream_copy"

    log_warn "DIFF  $file -> $diff_file"
    DIFFS_GENERATED=$((DIFFS_GENERATED + 1))
  else
    SKIPPED=$((SKIPPED + 1))
  fi
done < <(read_manifest_array "categories.adapted.files")

# --- Phase 3: Fix missing symlinks ---

log_info "Phase 3: Checking symlinks..."

while IFS= read -r symlink; do
  if [[ ! -e "$symlink" ]]; then
    # Determine the symlink target from upstream
    upstream_link="$UPSTREAM_DIR/$symlink"
    if [[ -L "$upstream_link" ]]; then
      target="$(readlink "$upstream_link")"
      mkdir -p "$(dirname "$symlink")"
      ln -s "$target" "$symlink"
      log_ok "SYMLINK  $symlink -> $target"
      SYMLINKS_FIXED=$((SYMLINKS_FIXED + 1))
    elif [[ -f "$upstream_link" ]]; then
      # Upstream has a real file, not a symlink — copy it
      mkdir -p "$(dirname "$symlink")"
      cp "$upstream_link" "$symlink"
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

  # Skip .git, .DS_Store, changes/
  [[ "$rel_path" == .git/* ]] && continue
  [[ "$rel_path" == *.DS_Store ]] && continue
  [[ "$rel_path" == ai-specs/changes/* ]] && continue
  [[ "$rel_path" == .manifest.json ]] && continue
  [[ "$rel_path" == ai-specs/.manifest.json ]] && continue

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
  log_warn "Add these to .manifest.json under the appropriate category."
fi

# --- Summary ---

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  ai-specs Update Summary${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "  Files updated (overwritten):  ${GREEN}$UPDATED${NC}"
echo -e "  Files unchanged (skipped):    $SKIPPED"
echo -e "  Diffs to review:              ${YELLOW}$DIFFS_GENERATED${NC}"
echo -e "  Symlinks fixed:               $SYMLINKS_FIXED"
echo -e "  Missing from upstream:        $MISSING_UPSTREAM"
echo -e "  New upstream files:           ${#NEW_FILES[@]}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

if [[ $DIFFS_GENERATED -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}Adapted files have upstream changes. Review diffs in:${NC}"
  echo -e "  $REVIEW_DIR/"
  echo ""
  echo -e "Run ${CYAN}/update-ai-specs${NC} to AI-merge the pending diffs."
fi

exit 0
