# Apply-script evidence index (2026-10-31; refreshed EVENT-DOCS-05)

Script under test: `scripts/apply-event-patches.ps1`,
SHA-256 `8CB2F8031ADDF939209005B094EC412DE21203414C8F36DC12936CD506693044`.
Patches: manifest-pinned 0001/0002/0003 (hashes in each transcript header).
Harness: each case ran the script in a child `powershell.exe -NoProfile
-NonInteractive` process against a disposable worktree; transcripts record
raw stdout/stderr, process exit codes, and before/after
(`rev-parse HEAD`, `--git-path index`, `status --porcelain`,
`diff --cached --quiet HEAD` exit). No installs, fetches, builds, or
network; no `.maos` inspection.

| Transcript | Case | Exit | Result |
|---|---|---:|---|
| `01-positive.txt` | clean base → full chain | 0 | PASS + independent `write-tree` = tip tree `53305f48…` |
| `02-idempotent.txt` | immediate rerun, index untouched | 0 | PASS ("already applied", re-verified) |
| `03-wrongbase.txt` | checkout at `256befbb` | 1 | PASS, target untouched |
| `04-dirty.txt` | foreign worktree modification | 1 | PASS, "unrecognized modifications" |
| `05-partial.txt` | 0001 applied only | 1 | PASS, "0001 applied; 0002 and 0003 pending" |
| `06-staged.txt` | tree == tip but staged in real index | 1 | PASS, staged gate fires (never "already applied") |
| `07-hash.txt` | corrupted 0002 copy | 1 | PASS, manifest mismatch, nothing applied |
| `08-envguard.txt` | ambient `GIT_INDEX_FILE` | 1 | PASS, fail-closed refusal |
| `09-gitdir.txt` | ambient `GIT_DIR` | 1 | PASS, fail-closed refusal |
| `10-gitworktree.txt` | ambient `GIT_WORK_TREE` | 1 | PASS, fail-closed refusal |

Guards evidenced: ambient `GIT_INDEX_FILE`/`GIT_DIR`/`GIT_WORK_TREE` fail
closed at startup and at every verification, with the real index path
explicitly resolved and compared; staged-only differences fail closed and
are never classified idempotent. Whether this `evidence/` directory ships
to the event repo is an owner D5 decision.
