# Apply-script evidence index — APPLY-SCRIPT-07 (2026-10-31)

Script under test: `scripts/apply-event-patches.ps1`,
SHA-256 `2B8674AA323C98ABDD9E5A54FDCBFF61332E715286CA690CC9BD530DA5C256A7`
(index-path normalization fix over `8CB2F803…`; all guards preserved).
Patches: manifest-pinned 0001/0002/0003 (hashes in each transcript header).
Durable regression test: `scripts/test-apply-script.ps1` (kept with the
project; refuses retained paths such as `C:\clean\core`).

Bug fixed: `git rev-parse --git-path index` returns relative `.git/index`
in normal clones; the script compared it directly with an absolute path and
falsely refused after applying 0001 (RUNLOG evidence: exit 1, 93 status
entries, real index untouched — reproduced here as `00-prefailure.txt`
with identical signature). Fix requests `--path-format=absolute` (falls
back to plain output) and normalizes any still-relative result against the
target checkout before comparing. Prior `evidence/apply-script-06/` is
preserved untouched.

Harness: each case ran the script in a child `powershell.exe -NoProfile
-NonInteractive` process against a disposable fixture (local-path clones —
no network — or linked worktrees); transcripts record raw stdout/stderr,
process exit codes, and before/after (`rev-parse HEAD`, `--git-path
index` plain + absolute, `status --porcelain`, `diff --cached --quiet
HEAD` exit). `C:\clean\core` (retained failed partial run) was never
touched, reused, or reset. No installs, builds, hosted calls, commits, or
publication; no `.maos` inspection.

| Transcript | Fixture | Exit | Result |
|---|---|---:|---|
| `00-prefailure.txt` | normal clone, UNFIXED script | 1 | reproduced RUNLOG signature (relative `.git/index` refusal, 93 status lines) |
| `selftest.txt` | durable test, attempt 2 | 0 | 7/7 asserts PASS, fixtures self-cleaned |
| `selftest-attempt1-harness-bug.txt` | durable test, attempt 1 | 1 | test-harness stderr bug (fixed in test; product untouched) |
| `01-positive.txt` | normal clone | 0 | PASS + independent `write-tree` = tip tree `53305f48…` |
| `02-idempotent.txt` | same clone, rerun | 0 | PASS ("already applied", re-verified) |
| `03-wrongbase.txt` | normal clone @ `256befbb` | 1 | PASS, target untouched |
| `04-dirty.txt` | normal clone + foreign edit | 1 | PASS, "unrecognized modifications" |
| `05-partial.txt` | normal clone + 0001 only | 1 | PASS, "0001 applied; 0002 and 0003 pending" |
| `06-staged.txt` | normal clone, tree==tip staged | 1 | PASS, staged gate fires (never "already applied") |
| `07-hash.txt` | corrupted 0002 copy | 1 | PASS, manifest mismatch, nothing applied |
| `08-envguard.txt` | ambient `GIT_INDEX_FILE` | 1 | PASS, fail-closed refusal |
| `09-gitdir.txt` | ambient `GIT_DIR` | 1 | PASS, fail-closed refusal |
| `10-gitworktree.txt` | ambient `GIT_WORK_TREE` | 1 | PASS, fail-closed refusal |
| `11-wt-positive.txt` | linked worktree | 0 | PASS (absolute-path regression) |
| `12-wt-idempotent.txt` | same worktree, rerun | 0 | PASS |
| `13-wt-staged.txt` | linked worktree, staged | 1 | PASS, staged gate fires |
