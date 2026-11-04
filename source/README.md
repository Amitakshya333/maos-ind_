# source/: the code written during the event

Every file in this folder was **created** between 2026-10-28 and 2026-11-04 for the Meta hackathon. Nothing in here existed in MAOS Core before the event.

- **For reading.** Paths mirror the real project layout, so `source/src/service/ring-agent-service.ts` is `src/service/ring-agent-service.ts` in the built tree.
- **Not the build path.** `scripts/setup.sh` and `scripts/setup.ps1` build from the pinned base plus [`../patches/`](../patches/). This folder is a readable copy of the result.
- **Byte-identical.** Each file matches what the 33 patches produce on top of base `f9525055c56a7f7771dd2fa029c147c2960a98a3`. To check, run setup, then `sha256sum -c SHA256SUMS` from inside the built tree.
- **Changed files are elsewhere.** Files that existed before the event and were modified are listed in [`../CHANGED_FILES.md`](../CHANGED_FILES.md), with full diffs in the patches.

## Where to start reading

| If you want to see… | Read |
|---|---|
| The agent loop, threads, streaming events, hybrid routing | [`src/service/ring-agent-service.ts`](src/service/ring-agent-service.ts) |
| The approval gate: which tools need a human | [`src/service/ring-tool-registry.ts`](src/service/ring-tool-registry.ts) |
| Restart refusal, prompt-injection guard, raw-CSV stripping | [`src/service/ring-safety.ts`](src/service/ring-safety.ts) |
| The 15 tools | [`src/service/ring-tools/`](src/service/ring-tools/) |
| The 6 shift skills (handover, rca, permit, loto, sop, report) | [`src/service/ring-skills.ts`](src/service/ring-skills.ts), [`src/service/ring-skill-workflows.ts`](src/service/ring-skill-workflows.ts) |
| The Meta model policy lock (endpoint + model) | [`src/backends/meta-api-policy.ts`](src/backends/meta-api-policy.ts) |
| The terminal agent: REPL, headless `-p --json`, exit codes | [`src/industrial/ring-cli.ts`](src/industrial/ring-cli.ts) |
| The Industrial TUI home screen | [`src/industrial/industrial-tui.ts`](src/industrial/industrial-tui.ts) |
| The desktop GUI: workspace, overlay, streaming panels | [`src/gui/src/components/`](src/gui/src/components/) |
| The global hotkey and overlay window | [`desktop/ring-overlay-host.cjs`](desktop/ring-overlay-host.cjs) |
| Safety and contract tests | [`tests/industrial/`](tests/industrial/) |
