# TASK SUBMISSION-ASSEMBLE-01: rebuild the reviewed Ring submission (Windows).
#
# Evidence-only: BASETEN_API_KEY must be UNSET for the whole run. This script
# refuses when it is set and never sets a key. No hosted calls.
#
# What it does, in order:
#   1. Blobless-clones public MAOS (https://github.com/Amitakshya333/maos.git)
#      with --no-checkout into a NEW target dir (default .\maos-submission),
#      then checks out ONLY the exact base tree. (A full Windows checkout of
#      HEAD trips on over-long review-packet paths; blobless + detached base
#      avoids that and downloads less.)
#   2. Verifies `git rev-parse HEAD` equals the exact detached base SHA
#      f9525055c56a7f7771dd2fa029c147c2960a98a3, failing closed on mismatch.
#   3. Applies the 33 submission patches in ..\patches\ in order with
#      `git am`, failing closed (with `git am --abort`) on any failure.
#   4. Runs `npm ci`, then `npm run build:backend`.
#   5. Runs `npm link` (best-effort; usually needs elevation/Developer Mode
#      on Windows) so the next command resolves, then prints the exact next
#      command: maos-industrial ring --demo.
#
# Idempotent-safe: REFUSES to run when the target dir already exists. To
# re-run, remove the target dir or pass a fresh one. Never re-applies
# patches twice.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\setup.ps1 [target-dir]
param(
  [string]$Target = "maos-submission"
)

$ErrorActionPreference = "Stop"
$BaseSha = "f9525055c56a7f7771dd2fa029c147c2960a98a3"
$RepoUrl = "https://github.com/Amitakshya333/maos.git"
$ExpectedPatches = 33

function Fail($msg) { Write-Error "SETUP FAILED: $msg"; exit 1 }

# --- 0. Evidence-only guard: key must be unset throughout -----------------------
if ($env:BASETEN_API_KEY -and $env:BASETEN_API_KEY.Trim() -ne "") {
  Fail "BASETEN_API_KEY is set in this shell; remove it first (evidence-only path, no hosted calls)."
}
Write-Host "BASETEN_API_KEY unset: ok"

# --- 1. Target dir (must be fresh) -------------------------------------------------
if (Test-Path $Target) {
  Fail "target '$Target' already exists -- refusing to run twice in the same dir. Remove it or pass a fresh target dir."
}

# --- 2. Locate the 33 submission patches (sibling of this script) -------------------
$PatchDir = Join-Path $PSScriptRoot "..\patches"
if (-not (Test-Path $PatchDir)) { Fail "patches dir not found: $PatchDir" }
$PatchFiles = Get-ChildItem (Join-Path $PatchDir "*.patch") | Sort-Object Name
if ($PatchFiles.Count -ne $ExpectedPatches) {
  Fail "expected $ExpectedPatches patches in $PatchDir, found $($PatchFiles.Count)"
}

# --- 3. Toolchain -----------------------------------------------------------------------
foreach ($cmd in @("git", "node", "npm")) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "$cmd is not on PATH" }
}
$nodeVer = (& node --version) -replace '[^0-9.]', ''
$nodeMajor = [int]($nodeVer.Split('.')[0])
if ($nodeMajor -lt 20) { Fail "Node.js 20+ required; found $(& node --version)" }
Write-Host "toolchain ok: $(& git --version), node $(& node --version), npm $(& npm --version)"

# --- 4. Blobless clone with no checkout, then check out the base tree only --------------
& git clone --filter=blob:none --no-checkout $RepoUrl $Target
if ($LASTEXITCODE -ne 0) { Fail "git clone $RepoUrl failed" }
& git -C $Target checkout --detach $BaseSha
if ($LASTEXITCODE -ne 0) { Fail "checkout of $BaseSha failed (base tree)" }
Write-Host "cloned $RepoUrl -> $Target (blobless, base tree only)"

# --- 5. Verify exact detached base SHA, fail closed ---------------------------------------
$HeadSha = (& git -C $Target rev-parse HEAD).Trim()
if ($HeadSha -ne $BaseSha) { Fail "base SHA mismatch: expected $BaseSha, got $HeadSha" }
Write-Host "base pinned: $HeadSha (verified)"

# --- 6. Apply the 33 patches in order, fail closed ----------------------------------------------
$patchPaths = $PatchFiles | ForEach-Object { $_.FullName }
& git -C $Target am $patchPaths
if ($LASTEXITCODE -ne 0) {
  & git -C $Target am --abort 2>$null
  Fail "patch apply failed (git am aborted; target left at clean base $BaseSha)"
}
Write-Host "patches applied: $ExpectedPatches/33 (git am exit 0)"

# --- 7. Install + backend build -------------------------------------------------------------------
Push-Location $Target
try {
  & npm ci
  if ($LASTEXITCODE -ne 0) { Fail "npm ci failed" }
  Write-Host "npm ci: ok"
  & npm run build:backend
  if ($LASTEXITCODE -ne 0) { Fail "npm run build:backend failed" }
  Write-Host "npm run build:backend: ok"
} finally {
  Pop-Location
}
if (-not (Test-Path (Join-Path $Target "dist\industrial\entrypoint.js"))) {
  Fail "build output missing: dist\industrial\entrypoint.js"
}

# --- 8. Expose the bins (best-effort) + success marker ------------------------------------------------
Push-Location $Target
try {
  & npm link
  if ($LASTEXITCODE -eq 0) {
    Write-Host "npm link: ok (maos-industrial should now resolve; undo with: npm unlink -g maosorch)"
  } else {
    Write-Host "WARNING: npm link failed (often elevation/Developer Mode on Windows)."
    Write-Host "Fallback: node dist\industrial\entrypoint.js ring --demo"
  }
} finally {
  Pop-Location
}
$AbsTarget = (Resolve-Path $Target).Path
"$BaseSha applied $ExpectedPatches patches $((Get-Date).ToUniversalTime().ToString('u'))" | Out-File (Join-Path $Target ".submission-setup-done") -Encoding utf8
Write-Host "marker written: $Target\.submission-setup-done"

# --- 9. Exact next command ----------------------------------------------------------------------------------
Write-Host ""
Write-Host "SETUP OK. Next command:"
Write-Host "  cd $AbsTarget; maos-industrial ring --demo"
Write-Host "Expected: bottom-line verdict CRITICAL with RMS 2.637, exit 0, EVIDENCE-ONLY badge, no keys."
