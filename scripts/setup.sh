#!/usr/bin/env bash
# TASK SUBMISSION-ASSEMBLE-01: rebuild the reviewed Ring submission.
#
# Evidence-only: BASETEN_API_KEY must be UNSET for the whole run. This script
# refuses when it is set and never exports a key. No hosted calls.
#
# What it does, in order:
#   1. Blobless-clones public MAOS (https://github.com/Amitakshya333/maos.git)
#      with --no-checkout into a NEW target dir (default ./maos-submission),
#      then checks out ONLY the exact base tree. (A full Windows checkout of
#      HEAD trips on over-long review-packet paths; blobless + detached base
#      avoids that and downloads less.)
#   2. Verifies `git rev-parse HEAD` equals the exact detached base SHA
#      f9525055c56a7f7771dd2fa029c147c2960a98a3, failing closed on mismatch.
#   3. Applies the 33 submission patches in ../patches/ in order with
#      `git am`, failing closed (with `git am --abort`) on any failure.
#   4. Runs `npm ci`, then `npm run build:backend`.
#   5. Runs `npm link` (best-effort) so the next command resolves, then
#      prints the exact next command: maos-industrial ring --demo.
#
# Idempotent-safe: REFUSES to run when the target dir already exists. To
# re-run, remove the target dir or pass a fresh one. Never re-applies
# patches twice.
#
# Usage:
#   bash scripts/setup.sh [target-dir]
set -u

BASE_SHA="f9525055c56a7f7771dd2fa029c147c2960a98a3"
REPO_URL="https://github.com/Amitakshya333/maos.git"
EXPECTED_PATCHES=33

fail() { echo "SETUP FAILED: $1" >&2; exit 1; }
info() { echo "$1"; }

# --- 0. Evidence-only guard: key must be unset throughout -----------------------
if [ -n "${BASETEN_API_KEY:-}" ]; then
  fail "BASETEN_API_KEY is set in this shell; unset it first (evidence-only path, no hosted calls)."
fi
info "BASETEN_API_KEY unset: ok"

# --- 1. Target dir (must be fresh) -------------------------------------------
TARGET="${1:-maos-submission}"
if [ -e "$TARGET" ]; then
  fail "target '$TARGET' already exists -- refusing to run twice in the same dir. Remove it or pass a fresh target dir."
fi

# --- 2. Locate the 33 submission patches (sibling of this script) --------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/../patches"
[ -d "$PATCH_DIR" ] || fail "patches dir not found: $PATCH_DIR"
PATCH_COUNT="$(ls -1 "$PATCH_DIR"/*.patch 2>/dev/null | wc -l | tr -d ' ')"
[ "$PATCH_COUNT" = "$EXPECTED_PATCHES" ] || fail "expected $EXPECTED_PATCHES patches in $PATCH_DIR, found $PATCH_COUNT"

# --- 3. Toolchain ------------------------------------------------------------
command -v git >/dev/null 2>&1 || fail "git is not on PATH"
command -v node >/dev/null 2>&1 || fail "node is not on PATH (Node.js 20+ required)"
command -v npm >/dev/null 2>&1 || fail "npm is not on PATH (required alongside Node.js)"
NODE_MAJOR="$(node --version 2>/dev/null | tr -d 'v\r\n ' | cut -d. -f1)"
case "$NODE_MAJOR" in ''|*[!0-9]*) fail "could not parse node version" ;; esac
[ "$NODE_MAJOR" -ge 20 ] || fail "Node.js 20+ required; found $(node --version)"
info "toolchain ok: $(git --version | head -n 1), node $(node --version), npm $(npm --version)"

# --- 4. Blobless clone with no checkout, then check out the base tree only ----
git clone --filter=blob:none --no-checkout "$REPO_URL" "$TARGET" \
  || fail "git clone $REPO_URL failed"
git -C "$TARGET" checkout --detach "$BASE_SHA" \
  || fail "checkout of $BASE_SHA failed (base tree)"
info "cloned $REPO_URL -> $TARGET (blobless, base tree only)"

# --- 5. Verify exact detached base SHA, fail closed --------------------------
HEAD_SHA="$(git -C "$TARGET" rev-parse HEAD)" || fail "rev-parse HEAD failed"
[ "$HEAD_SHA" = "$BASE_SHA" ] || fail "base SHA mismatch: expected $BASE_SHA, got $HEAD_SHA"
info "base pinned: $HEAD_SHA (verified)"

# --- 6. Apply the 33 patches in order, fail closed ---------------------------
if ! git -C "$TARGET" am "$PATCH_DIR"/*.patch; then
  git -C "$TARGET" am --abort >/dev/null 2>&1 || true
  fail "patch apply failed (git am aborted; target left at clean base $BASE_SHA)"
fi
info "patches applied: $EXPECTED_PATCHES/33 (git am exit 0)"

# --- 7. Install + backend build ---------------------------------------------
(cd "$TARGET" && npm ci) || fail "npm ci failed"
info "npm ci: ok"
(cd "$TARGET" && npm run build:backend) || fail "npm run build:backend failed"
info "npm run build:backend: ok"
[ -f "$TARGET/dist/industrial/entrypoint.js" ] || fail "build output missing: dist/industrial/entrypoint.js"

# --- 8. Expose the bins (best-effort) + success marker ---------------------
ABS_TARGET="$(cd "$TARGET" && pwd)"
if (cd "$TARGET" && npm link); then
  info "npm link: ok (maos-industrial should now resolve; undo with: npm unlink -g maosorch)"
else
  info "WARNING: npm link failed (often elevation on Windows). Fallback from $ABS_TARGET:"
  info "  node dist/industrial/entrypoint.js ring --demo"
fi
echo "$BASE_SHA applied $EXPECTED_PATCHES patches $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$TARGET/.submission-setup-done"
info "marker written: $TARGET/.submission-setup-done"

# --- 9. Exact next command -------------------------------------------------
info ""
info "SETUP OK. Next command:"
info "  cd $ABS_TARGET && maos-industrial ring --demo"
info "Expected: bottom-line verdict CRITICAL with RMS 2.637, exit 0, EVIDENCE-ONLY badge, no keys."
