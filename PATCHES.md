# Ring submission — patch set

- Base SHA: `f9525055c56a7f7771dd2fa029c147c2960a98a3`
  (the `pre-event-base` tag is LOCAL ONLY — never pushed; pin the exact SHA
  in scripts and docs.)
- HEAD SHA: `82b37fe5432ab271273bdc4417b5b860b74591d8`
- Patch count: 33 (one commit each, `git am`-ready, numbered 0001–0033)
- Total bytes (all 33 `.patch` files): 3097145
- Unique files touched across the set: 238
- Range shape: `f952505..82b37fe` is 35 commits = 33 non-merge commits +
  2 `origin/ring/linux` merges. This set keeps the 33 non-merge commits and
  drops the 2 merges (patch 25 is the trimmed, reviewer-safe 6-file version
  of the checkpoint commit — staging/worktree-local files excluded).
- Apply result: `git am patches/*.patch` on a fresh checkout of the base SHA
  exits 0 (verified on 2026-11-04; see `run-log.md`).

## How generated

The trimmed set was derived from the public repo history with an explicit
trim of the checkpoint commit (see range note above):

```bash
git format-patch f9525055c56a7f7771dd2fa029c147c2960a98a3..82b37fe5432ab271273bdc4417b5b860b74591d8 -o patches/
# then: replace 0025 with the trimmed 6-file version
```

Every file in `patches/` is byte-identical to the corresponding
`git format-patch` output except `0025`, which is the documented
trimmed 6-file checkpoint (`.gitignore`, `.maos/maos.config.json`,
`.maos/pool.json`, `docs/product/RING_AGENT_PM_HANDOFF_3.md`,
`read-only-completion.patch`,
`src/gui/src/components/RingWorkspace.tsx`).

## Contents (one line per patch)

| # | File | Subject |
|---|------|---------|
| 01 | 0001-Add-audited-Industrial-agent-workflows.patch | Add audited Industrial agent workflows |
| 02 | 0002-Enforce-Meta-provider-and-Industrial-agent-limits.patch | Enforce Meta provider and Industrial agent limits |
| 03 | 0003-Harden-installation-and-project-Git-discovery.patch | Harden installation and project Git discovery |
| 04 | 0004-Handle-npm-stderr-in-bootstrap-installer.patch | Handle npm stderr in bootstrap installer |
| 05 | 0005-Add-bounded-Industrial-agent-and-provider-workflows.patch | Add bounded Industrial agent and provider workflows |
| 06 | 0006-Fix-pilot-cancellation-callback-lifetime.patch | Fix pilot cancellation callback lifetime |
| 07 | 0007-Set-Baseten-reasoning-output-budget.patch | Set Baseten reasoning output budget |
| 08 | 0008-Reconcile-GUI-selection-binding-and-REST-cancellatio.patch | Reconcile GUI selection binding and REST cancellation |
| 09 | 0009-Remove-unused-simple-git-dependency.patch | Remove unused simple-git dependency |
| 10 | 0010-Show-completion-refusal-in-the-telemetry-panel.patch | Show completion refusal in the telemetry panel |
| 11 | 0011-Add-judge-verifier-for-audit-exports.patch | Add judge verifier for audit exports |
| 12 | 0012-Add-Ring-as-the-primary-agent-surface.patch | Add Ring as the primary agent surface |
| 13 | 0013-Add-hosted-Ring-inference-service.patch | Add hosted Ring inference service |
| 14 | 0014-Add-the-Ring-agent-loop-and-workspace.patch | Add the Ring agent loop and workspace |
| 15 | 0015-Document-Ring-agent-plans-and-ignore-local-worktrees.patch | Document Ring agent plans and ignore local worktrees |
| 16 | 0016-Freeze-Ring-contracts-for-threads-streams-and-tools.patch | Freeze Ring contracts for threads streams and tools |
| 17 | 0017-Add-Ring-brain-tools-and-threads.patch | Add Ring brain tools and threads |
| 18 | 0018-Add-Ring-overlay-and-workspace-surface.patch | Add Ring overlay and workspace surface |
| 19 | 0019-Add-Ring-roles-skills-and-safety.patch | Add Ring roles skills and safety |
| 20 | 0020-Document-frozen-Ring-contract-and-preflight.patch | Document frozen Ring contract and preflight |
| 21 | 0021-Add-Ring-Day-2-streaming-skills-and-surface.patch | Add Ring Day-2 streaming skills and surface |
| 22 | 0022-Route-bookkeeping-through-deterministic-skills.patch | Route bookkeeping through deterministic skills |
| 23 | 0023-Fix-overlay-window-and-approval-artifacts.patch | Fix overlay window and approval artifacts |
| 24 | 0024-Document-Ring-hosted-integration-and-demo-script.patch | Document Ring hosted integration and demo script |
| 25 | 0025-pre-linux-enablement-checkpoint.patch | pre-linux-enablement checkpoint (trimmed: 6 files) |
| 26 | 0026-Linux-enablement-honest-Windows-adapter-degradation-.patch | Linux enablement: honest Windows-adapter degradation |
| 27 | 0027-Add-Ring-CLI-and-overlay-feel-pass.patch | Add Ring CLI and overlay feel pass |
| 28 | 0028-docs-update-linux-runbook-with-verified-CLI-runs-and.patch | docs: update linux runbook with verified CLI runs |
| 29 | 0029-Polish-Ring-REPL-rendering.patch | Polish Ring REPL rendering |
| 30 | 0030-Add-Ring-TUI-home-screen-and-agent-mode.patch | Add Ring TUI home screen and agent mode |
| 31 | 0031-Fix-Ring-TUI-home-rendering.patch | Fix Ring TUI home rendering |
| 32 | 0032-Center-industrial-TUI-layout.patch | Center industrial TUI layout |
| 33 | 0033-Add-Ring-release-packaging.patch | Add Ring release packaging |

## Secret scan

CLEAN. No private keys, no `sk-ant-*`, no credential assignments found in
any of the 33 patches. (One grep hit on the word "reserved" inside a prose
planning doc in patch 15 is a sentence about env-var naming, not a secret.)

## Notes

- No tags are pushed by this submission (PM decision). The base is pinned by
  the exact SHA `f9525055c56a7f7771dd2fa029c147c2960a98a3` everywhere.
- `LICENSE` is unchanged between base and HEAD (MIT carries over from base).
