# MAOS Ring: an on-premise industrial agent powered by Meta's Muse Spark Open (via Baseten). Claude Code for the plant floor.

## Demo video

[Demo video — link to be added]

## Screenshots

![Ring CLI home TUI at 100 cols](docs/screenshots/01-cli-home.png)
Home TUI (real run, evidence-only): CEO banner, operator input card, SYSTEMS panel with T-07 CRITICAL RMS 2.637 — centered 90-col stage at 100 cols.

![Ring answering the turbine question](docs/screenshots/02-ring-turbine.png)
Ring mode answering the turbine question (real run, evidence-only): `analyze_telemetry` tool chips, CRITICAL verdict line, RMS 2.637, cited CSV source.

![Ring approval card](docs/screenshots/03-approval-card.png)
Approval card (real run): `/handover` pauses on the bordered approval card with the `Approve ... ? [y/N]` prompt (default No) — answered N here.

![Ring refusal](docs/screenshots/04-refusal.png)
Refusal in the terminal (real run): a restart request gets the calm fail-closed refusal — no action, no files, headless exit code 2.

![Ring overlay](docs/screenshots/05-gui-overlay.png)
GUI overlay, `#/ring-overlay` (real headless Electron offscreen capture): the compact always-on-top companion over the same store, empty state with no run attached. No approval card is visible because no live run was attached offscreen — not faked. See `CAPTIONS.md` for the capture log.

Screenshot provenance (commands, exit codes, SHAs): [`CAPTIONS.md`](CAPTIONS.md). Architecture source: [`ARCHITECTURE.mmd`](ARCHITECTURE.mmd).

## How it fits together

```mermaid
graph TD
    Employee[Employee - plain-language question] --> RingCLI[Ring CLI and TUI - REPL by default, headless with -p, home screen]
    Employee --> RingGUI[Ring GUI overlay - Ctrl Shift Space, Allow Deny cards]
    RingCLI --> AgentLoop[Ring agent loop - threads, skills, registry, approvals]
    RingGUI --> AgentLoop
    AgentLoop --> MetaModel[Meta model via Baseten - Muse Spark Open reasoning]
    AgentLoop --> DetEngine[Deterministic engine - telemetry verdict, audit chain, artifacts]
    MetaModel --> EvidenceTools[Evidence tools - analyze_telemetry, read_company_document, search_knowledge, verify_export]
    EvidenceTools --> Findings[Findings - never verdicts]
    Findings --> DetEngine
    DetEngine --> ApprovalGate[Approvals gate - human y N, default No, fail-closed]
    ApprovalGate --> ArtifactsOK[Artifacts - DOCX and MD work orders, audit export]
    ApprovalGate --> RefusalPath[Refusal path - restart and operation requests]
    RefusalPath --> CalmRefusal[Calm refusal - decision support only, no files written]
    DetEngine --> AuditTrail[Tamper-evident audit - every event in maos ring-runs]
    AuditTrail --> ArtifactsOK
```

## What it does

- Ask in plain language; get deterministic verdicts with sources — turbine telemetry, SOP, maintenance note, audit chain.
- Approval-gated work orders and artifacts; Ring calmly refuses operating decisions ("decision support, not operating authority").
- Tamper-evident audit plus a reproducible setup: exact base SHA, 33 ordered patches, fail-closed scripts.

## How it uses Meta's model

The hybrid is deliberate:

- The **model** plans and runs the EVIDENCE tools — telemetry (`analyze_telemetry`), SOP (`read_company_document`), search (`search_knowledge`), verify (`verify_export`) — proven 3/3 live.
- The **engine** owns records, approvals, and refusal deterministically, server-side. The model never authorizes an operation.
- The 3/4 live reliability finding — the memory-and-plan miss, stable across 3 runs — is what motivated the hybrid: the model proposes, the deterministic engine disposes.

Model id (byte-exact): `meta-models/muse-spark-open-1026` via `https://inference.baseten.co/v1`.

## What existed before vs what we built this week

**Before.** MAOS Core at `f9525055c56a7f7771dd2fa029c147c2960a98a3` (public maos.git): the multi-agent orchestrator — fleet config, provider backends, CLI/REPL, audit chain — plus the sovereign Industrial profile (deterministic T-07 judged run, Rust-backed audit, offline stores).

**This week — Ring.** A deterministic, evidence-first agent loop (instruction in, plan + tool steps streamed as events, human approval on consequential actions, every event persisted to `.maos/ring-runs`); the `maos-industrial ring` CLI (REPL by default, headless with `-p`, `ring --demo` first-run pack); the Industrial TUI home screen with the same streaming feel; the Ring Workspace GUI plus overlay host with Allow/Deny cards over the same store; six frozen skills (handover, rca, permit, loto, sop, report) with prompt-injection guards; fail-closed safety throughout; the bundled synthetic T-07/P-12 demo pack; unsigned `electron-builder` packaging.

Base pin only: `f9525055c56a7f7771dd2fa029c147c2960a98a3`. No other tags or SHAs apply.

## Quickstart — Linux CLI

Run from the packet directory (`setup.sh` performs the clone itself — exact base SHA, verified with `rev-parse`, fail closed):

```bash
bash scripts/setup.sh maos-submission
cd maos-submission && maos-industrial ring --demo
```

`setup.sh` applies the 33 patches in `patches/` in order (fail closed, `git am --abort` on failure), runs `npm ci` + `npm run build:backend`, best-effort `npm link`, then prints the next command. It refuses to run twice in the same dir. Expected: verdict CRITICAL, overall RMS 2.637, `EVIDENCE-ONLY` badge, exit 0.

## Quickstart — Windows CLI

Run from the packet directory:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
cd maos-submission; maos-industrial ring --demo
```

Same behavior: exact base SHA, 33 patches in order, `npm ci` + `npm run build:backend`, best-effort `npm link`, CRITICAL / RMS 2.637 / `EVIDENCE-ONLY`, exit 0.

## Quickstart — Windows GUI (run from source, unsigned)

Run from the built tree root (`maos-submission` after setup):

```powershell
npm ci --prefix desktop
node desktop/node_modules/electron/install.js
npm run build
```

Unsigned: no certificate, no publisher attestation — Windows SmartScreen will warn. The SHA-256 manifest detects tampering; it does not prove provenance.

## Turning on hosted mode AFTER setup

1. Set `BASETEN_API_KEY` in the launching shell only — `export BASETEN_API_KEY="<key>"` (PowerShell: `$env:BASETEN_API_KEY="<key>"`); never committed, never in a file.
2. Add the `providers.baseten` block to the demo `.maos/maos.config.json` (`baseURL: https://inference.baseten.co/v1`, `model: meta-models/muse-spark-open-1026`, `basetenApiEnabled: true`) — armed at recording time only.
3. Badge check: the CLI/TUI must show `HOSTED`, not EVIDENCE-ONLY — evidence-only is the default.

## Honest limitations

- **Synthetic data only.** The demo reads bundled fixtures (T-07/P-12); nothing here measures real plant equipment.
- **Unsigned GUI, no installer.** No certificate, no publisher attestation — SmartScreen will warn.
- **Evidence-only without Baseten key.** Out of the box Ring runs the deterministic brief (`EVIDENCE-ONLY` badge); hosted reasoning needs the key plus the armed config.
- **Voice + P-12 vision NOT included.** The P-12 scan and photo ship in the pack but are not wired into evidence paths (scan needs OCR, photo needs vision weights) — Ring reports them unavailable rather than fabricate.
- **Decision support, not operating authority.** Ring summarizes evidence and refuses restart/operation authorization; the authorized engineer decides.

## License

MIT — the base repo `LICENSE` (Copyright (c) 2025 Amitakshya Sutar), unchanged by the patches.
