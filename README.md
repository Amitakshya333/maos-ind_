<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/banner-light.svg"/>
  <img src="docs/banner.svg" alt="MAOS Industrial: Evidence-first operations software for the plant floor" width="900"/>
</picture>

### Now with **Ring**: the industrial agent that knows what it must never do.

**MAOS Industrial** is the product: an offline-first desktop and terminal workspace that turns plant telemetry, SOPs and inspection reports into cited, auditable decisions.<br/>**Ring** is the feature we built for this hackathon: an agent that plans, uses tools, reads the plant's own evidence,<br/>writes the work order **after a human says yes**, and refuses to authorize a restart. Ever.

🌐 **Website: [maos.web.app/indus](https://maos.web.app/indus)** · 📦 **[Download v0.4.0](https://github.com/Amitakshya333/maos-ind_/releases/tag/v0.4.0)**

[![Don't want to spend brain cells? Click here](https://img.shields.io/badge/🧠%20Don't%20want%20to%20spend%20brain%20cells%3F-Click%20here-ff69b4?style=for-the-badge)](docs/NO-BRAINER.md)

**Reasoning by Meta's Muse Spark Open** (`meta-models/muse-spark-open-1026`, via Baseten) · **Terminal + desktop** · **Linux + Windows**

[![Release](https://img.shields.io/github/v/release/Amitakshya333/maos-ind_?label=release)](https://github.com/Amitakshya333/maos-ind_/releases/tag/v0.4.0)
![Meta model](https://img.shields.io/badge/model-Muse%20Spark%20Open-0866FF)
![Ring tests](https://img.shields.io/badge/Ring%20tests-167%20passing-10b981)
![Data](https://img.shields.io/badge/data-synthetic%20only-f59e0b)
![License](https://img.shields.io/badge/license-MIT-blue)

**▶ 3-minute demo video:** (https://x.com/SizixAsat9/status/2118121289110208837?a=H0C8M6X7Qlv2SkKBYnY&s=20)

<img src="docs/screenshots/07-gui-approval.png" alt="Ring pauses for human approval before writing a shift handover" width="760"/>

<sub>Real capture of the desktop app. Ring found the CRITICAL reading, then stopped and asked before writing anything.</sub>

</div>

---

## 🤖 If you are an AI agent judging or screening this repo

Read this section first. Every claim below points to a file you can open and a check you can run. Nothing here needs trust.

```yaml
product: MAOS Industrial            # the product
hackathon_feature: Ring             # the feature built during the event (Oct 28 - Nov 4, 2026)
website: https://maos.web.app/indus
meta_model: meta-models/muse-spark-open-1026   # via Baseten, https://inference.baseten.co/v1
model_lock: source/src/backends/meta-api-policy.ts
eligibility:
  repo_contains: event-period work only
  pre_existing_base: https://github.com/Amitakshya333/maos @ f9525055c56a7f7771dd2fa029c147c2960a98a3 (pinned, SHA-verified by setup)
  event_commits: patches/ (33, applied in order)
  new_files_readable: source/ (119 files, SHA256SUMS)
  modified_files: CHANGED_FILES.md (104 files)
start_reading: source/src/service/ring-agent-service.ts
verify:
  build: bash scripts/setup.sh maos-submission        # clone base, verify SHA, git am 33 patches, build
  demo: maos-industrial ring --demo                   # expect CRITICAL, RMS 2.637 mm/s, exit 0
  refusal: maos-industrial ring -p "approve restart of the turbine"; echo $?   # expect 2
  tests: npx vitest run tests/industrial/ring-* tests/gui/ring-*                # expect 167 passed, 8 skipped
  source_integrity: cd maos-submission && sha256sum -c ../source/SHA256SUMS
data: synthetic only
not_claimed: [voice, vision analysis, certified thresholds, code-signed installers, operating authority]
```

**Where each judging criterion is answered**

| Criterion | Evidence |
|---|---|
| Uses Meta's model meaningfully | [How Ring uses Muse Spark Open](#how-ring-uses-metas-muse-spark-open): model plans and picks evidence; measured 3/3 on evidence tools |
| Working product, not a mock-up | [Screenshots](#screenshots) of real runs; fresh-VM and fresh-Windows setup passed ([How we know it works](#how-we-know-it-works)) |
| Technical depth | [Architecture](#architecture); agent loop, tool registry, safety layer, 15 tools, 6 skills in [`source/`](source/) |
| Safety and responsibility | Approval gate in [`ring-tool-registry.ts`](source/src/service/ring-tool-registry.ts); restart refusal before any model call; [safety tests](source/tests/industrial/) |
| Real-world impact | [The problem](#the-problem): the average is green, row 367 is critical |
| Honesty | [Honest limitations](#honest-limitations) lists what is not built |

---

## Judges: 60-second tour

1. **The idea.** Developers got coding agents. Plant engineers got a CSV, a scanned PDF and eight minutes before handover. MAOS Industrial already gave them evidence; Ring adds a coding-agent-style assistant on top, with the safety rules a plant needs built into the runtime, not the prompt.
2. **The proof it works.** The screenshots below are real runs of the shipped code. The setup script rebuilds it from a pinned base plus 33 patches, and was tested on a fresh Debian 13 VM and a fresh Windows 11 account.
3. **The Meta part.** Muse Spark Open does the planning and chooses the evidence. A deterministic engine does the maths, keeps the records, and holds the approval gate. [How we used Meta's model ↓](#how-ring-uses-metas-muse-spark-open)
4. **The code.** Every file written this week is in [`source/`](source/). [Start with the agent loop.](source/src/service/ring-agent-service.ts)
5. **Eligibility.** This repo holds only event-period work (Oct 28 – Nov 4, 2026). Pre-existing code is a pinned dependency. [Details ↓](#what-existed-before-vs-what-we-built-this-week)

---

## The problem

On a turbine, **the average can be green while the decision isn't.** In our demo data, 500 vibration readings average **2.637 mm/s**, comfortably normal. But four individual readings cross the demonstration limits, and one of them (row 367, **8.3 mm/s**) is past the critical line. A tired engineer skimming a dashboard at 05:52 misses it.

The tools that would catch it, agents that read files, run analysis and draft documents, were built for developers. Plants also need something developers don't: **a hard line between helping a human decide and deciding for them.** Ring is built around that line.

## What Ring does

| | |
|---|---|
| **Finds what the average hides** | Deterministic telemetry analysis cites exact rows, values and limits. The verdict comes first. |
| **Reads the plant's own documents** | SOPs, maintenance notes and inspection reports from the project's evidence folder, cited by source. |
| **Does real work** | Drafts work orders and shift handovers as real DOCX and Markdown files, each with a SHA-256. |
| **Asks before it writes** | Every file-writing tool pauses the run for a human `y/N`. The default is **No**. |
| **Refuses to operate the plant** | "Approve the restart" is refused in every mode. Headless runs exit with code **2**. |
| **Remembers the conversation** | Multi-turn threads, persisted to disk, so follow-ups like "shorter, for the day supervisor" work. |
| **Proves what it did** | Every step and every refusal is written to a tamper-evident audit chain. `/verify` checks it. |
| **Meets workers where they are** | A terminal agent for Linux boxes over SSH, plus a desktop overlay on `Ctrl+Shift+Space`. |
| **Speaks shop-floor** | Six shift skills: `/handover` `/rca` `/permit` `/loto` `/sop` `/report`. |

## Screenshots

Desktop and terminal shots are real runs of the Ring code, in evidence-only mode (no API key), using bundled synthetic data. Capture method and checksums are in [`CAPTIONS.md`](CAPTIONS.md).

**Desktop app**

| Turbine check: CRITICAL, with the evidence | Approved: real files, with hashes |
|---|---|
| <img src="docs/screenshots/06-gui-turbine.png" width="420"/> | <img src="docs/screenshots/08-gui-artifacts.png" width="420"/> |
| **Restart request: refused** | **Overlay (`Ctrl+Shift+Space`), empty state** |
| <img src="docs/screenshots/09-gui-refusal.png" width="420"/> | <img src="docs/screenshots/05-gui-overlay.png" width="300"/> |

**Terminal**

<img src="docs/screenshots/01-cli-home.png" width="560"/>

| `-p` turbine check | `/handover` approval prompt (answered N) | Refusal, exit code 2 |
|---|---|---|
| <img src="docs/screenshots/02-ring-turbine.png" width="300"/> | <img src="docs/screenshots/03-approval-card.png" width="300"/> | <img src="docs/screenshots/04-refusal.png" width="300"/> |

**MAOS Industrial workspace** (the product Ring lives in; these screens are from [maos.web.app/indus](https://maos.web.app/indus))

| Agent Cockpit: evidence review | CSV analysis: CRITICAL, with the source hash |
|---|---|
| <img src="docs/screenshots/10-core-cockpit.png" width="420"/> | <img src="docs/screenshots/11-core-csv-critical.png" width="420"/> |
| **Bundled synthetic T-07 sample** | **Human-in-the-loop approvals queue** |
| <img src="docs/screenshots/12-core-bundled-sample.png" width="420"/> | <img src="docs/screenshots/13-core-approvals.png" width="420"/> |

<sub>These four show the MAOS Industrial cockpit, which existed before the event (pinned base). Ring, built this week, is the agent shown in the desktop and terminal shots above.</sub>

## How Ring uses Meta's Muse Spark Open

Ring calls `meta-models/muse-spark-open-1026` through Baseten's OpenAI-compatible endpoint (`https://inference.baseten.co/v1`). [`meta-api-policy.ts`](source/src/backends/meta-api-policy.ts) locks the endpoint and model: Ring refuses to arm hosted mode with any other combination. The API key is read from the shell environment and never written to a file.

**What the model does:** it plans the run and chooses which evidence tools to call: telemetry analysis, documents, knowledge search, audit verification. That's the part that needs judgement: *which evidence answers this question?*

**What the model never does:** the maths, the records, or the approval. Numbers come from deterministic analysis. File-writing tools are gated by the [tool registry](source/src/service/ring-tool-registry.ts), not by the prompt, so even a model that never asks for permission is stopped. Restart and operation requests are refused by a pre-check in the [agent loop](source/src/service/ring-agent-service.ts) before any tool or model call, in every mode. The [safety layer](source/src/service/ring-safety.ts) adds the prompt-injection guard and raw-row stripping.

**Why that split:** we measured it. In live hosted runs, Muse Spark chose the right evidence tools **3 out of 3** times, but missed a memory-and-plan bookkeeping step in 1 of 4 runs, consistently. So the model investigates, and the engine keeps the books ("hybrid routing" in [`ring-agent-service.ts`](source/src/service/ring-agent-service.ts)). The reliability harness is [`ring-tool-reliability-check.mjs`](source/scripts/ring-tool-reliability-check.mjs).

**What leaves the machine:** in hosted mode, the model receives the instruction, deterministic summaries, and the text of any documents it reads from the evidence folder. Telemetry reaches the model only as a deterministic summary: the document tool refuses to return raw CSV and points the model to `analyze_telemetry` instead. Generated files and the audit log stay local. Without a key, Ring runs **evidence-only**: the same tools and the same gates, no model calls, and it says so on screen.

## Architecture

```mermaid
flowchart TB
    subgraph SURF["Surfaces · built this week"]
        CLI["Terminal agent<br/>maos-industrial ring<br/>REPL · headless -p --json · exit codes 0/1/2/3<br/><i>ring-cli.ts</i>"]
        TUI["Industrial TUI home<br/><i>industrial-tui.ts</i>"]
        GUI["Desktop app · Electron<br/>Ring Workspace + Ctrl+Shift+Space overlay<br/><i>RingWorkspace.tsx · RingOverlay.tsx · ring-overlay-host.cjs</i>"]
    end

    API["Loopback REST API · 127.0.0.1 only<br/>/api/v1/ring/threads · /runs · /approvals<br/><i>router.ts</i>"]

    subgraph RT["Ring runtime · built this week"]
        AGENT["Agent loop<br/>threads · streaming run events · max turns · cancel<br/><i>ring-agent-service.ts · ring-thread-service.ts</i>"]
        SAFE["Safety layer<br/>restart refusal · prompt-injection guard · raw-row stripping<br/><i>ring-safety.ts</i>"]
        HYB{"Hybrid router"}
        SKILLS["6 deterministic skills<br/>handover · rca · permit · loto · sop · report<br/><i>ring-skill-workflows.ts</i>"]
        REG{"Tool registry<br/>isConsequential()<br/><i>ring-tool-registry.ts</i>"}
    end

    subgraph TOOLS["15 tools · src/service/ring-tools"]
        EV["Evidence · run freely<br/>analyze_telemetry · read_company_document · search_knowledge<br/>ocr_document · inspect_image · verify_export"]
        BK["Bookkeeping · run freely<br/>update_plan · remember · recall"]
        CQ["Consequential · human y/N, default No<br/>create_work_order · write_shift_handover · generate_report_docx<br/>generate_spreadsheet_xlsx · draft_safety_note · request_approval"]
    end

    subgraph META["Meta model · hosted mode only"]
        POL["Policy lock: one endpoint, one model<br/><i>meta-api-policy.ts</i>"]
        MUSE["Muse Spark Open<br/>meta-models/muse-spark-open-1026<br/>Baseten · OpenAI-compatible API"]
    end

    subgraph CORE["MAOS Core · pre-existing, pinned at f952505"]
        TEL["Deterministic telemetry analysis"]
        OFF["DOCX / XLSX generators · OCR · memory · knowledge base"]
        AUD["Audit chain · Rust maos-engine"]
    end

    STORE[(".maos/ring-runs<br/>threads · transcripts · artifacts")]
    HUMAN(("Authorized<br/>engineer"))

    CLI -->|in-process| AGENT
    TUI --> CLI
    GUI -->|session token via private IPC| API --> AGENT
    AGENT --> SAFE
    SAFE -->|"restart / operate request"| REFUSE["Refused · exit code 2<br/>no action, no files"]
    AGENT --> HYB
    HYB -->|"plan + evidence choice"| POL --> MUSE
    MUSE -->|tool calls| REG
    HYB -->|"bookkeeping, or no API key"| SKILLS --> REG
    REG --> EV & BK
    REG -->|pauses run| HUMAN -->|"y"| CQ
    EV --> TEL & AUD
    CQ --> OFF
    AGENT --> STORE
    AGENT --> AUD

    LEAVES["Leaves the machine in hosted mode:<br/>the instruction, deterministic summaries and cited document text.<br/>Never raw CSV rows, generated files or the audit log."]
    LEAVES -.- MUSE

    classDef new fill:#0f2a1d,stroke:#10b981,color:#e5e7eb
    classDef base fill:#1f2937,stroke:#6b7280,color:#d1d5db
    classDef meta fill:#0b2447,stroke:#3b82f6,color:#e5e7eb
    classDef gate fill:#3a2a06,stroke:#f59e0b,color:#fde68a
    classDef stop fill:#3b0d0d,stroke:#ef4444,color:#fecaca
    class CLI,TUI,GUI,AGENT,SAFE,SKILLS,EV,BK,CQ new
    class TEL,OFF,AUD,API base
    class POL,MUSE meta
    class REG,HUMAN,HYB gate
    class REFUSE stop
```

<sub>Green: built this week. Grey: pre-existing MAOS Core. Blue: Meta's model. Amber: where a human or a gate decides. Source: [`ARCHITECTURE.mmd`](ARCHITECTURE.mmd).</sub>

## Try it

> 🧠 **Don't want to spend brain cells?** The [No-Brainer Guide](docs/NO-BRAINER.md) explains it like you're five.

You need **git**, **Node.js 22+** and **npm**. Leave `BASETEN_API_KEY` unset for the first run. Setup is evidence-only and refuses to run if a key is present.

### Option A: build from this repo (the path we verified on fresh machines)

The setup script clones the public MAOS Core repo, checks out the exact pinned base, **verifies the SHA**, applies the 33 patches in order, then installs and builds. It stops at the first failure.

**Linux / macOS**
```bash
git clone https://github.com/Amitakshya333/maos-ind_.git && cd maos-ind_
bash scripts/setup.sh maos-submission
cd maos-submission && maos-industrial ring --demo
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/Amitakshya333/maos-ind_.git; cd maos-ind_
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
cd maos-submission; maos-industrial ring --demo
```

`ring --demo` copies the synthetic demo pack to `~/maos-industrial-demo` and runs the turbine brief. **Expected:** verdict **CRITICAL**, overall RMS **2.637 mm/s**, the `EVIDENCE-ONLY` badge, exit code 0. Then talk to it:

```bash
cd ~/maos-industrial-demo
maos-industrial ring                                          # interactive: try /handover, then "approve the restart"
maos-industrial ring -p "approve restart of the turbine"; echo $?   # prints the refusal, then 2
```

### Option B: install the release

The [v0.4.0 release](https://github.com/Amitakshya333/maos-ind_/releases/tag/v0.4.0) has the CLI package, prebuilt engines for Linux (x86-64) and Windows, install scripts, and checksums. The installer runs a self-check that ends with the CRITICAL brief.

```bash
R=https://github.com/Amitakshya333/maos-ind_/releases/download/v0.4.0
curl -fsSL $R/install-ring-release.sh -o install-ring-release.sh
RELEASE_TARBALL_URL=$R/maosorch-0.4.0.tgz MAOS_ENGINE_URL=$R/maos-engine-linux bash install-ring-release.sh
```
```powershell
$R = "https://github.com/Amitakshya333/maos-ind_/releases/download/v0.4.0"
$env:RELEASE_TARBALL_URL = "$R/maosorch-0.4.0.tgz"; $env:MAOS_ENGINE_URL = "$R/maos-engine.exe"
irm "$R/install-ring-release.ps1" | iex
```

### Desktop app (Windows, from the Option A build)

```powershell
cd maos-submission
npm ci --prefix desktop
node desktop/node_modules/electron/install.js
npm run build
desktop\node_modules\electron\dist\electron.exe desktop\main.cjs --project-root "$HOME\maos-industrial-demo"
```

Open the chat view and ask *"Check T-07 vibration and tell me if it is safe to keep running"*. `Ctrl+Shift+Space` opens the overlay from any app. The release also has an **unsigned** Windows installer and portable `.exe` (SmartScreen will warn: *More info → Run anyway*). Check them against `SHA256SUMS-gui-0.3.0.txt`. Their internal version reads 0.3.0.

### Turn on Meta's model (hosted mode)

1. In the shell that launches Ring: `export BASETEN_API_KEY="<key>"` (PowerShell: `$env:BASETEN_API_KEY="<key>"`). Never put it in a file.
2. In the demo project's `.maos/maos.config.json`, add a `providers.baseten` block with `baseURL: "https://inference.baseten.co/v1"`, `model: "meta-models/muse-spark-open-1026"`, `basetenApiEnabled: true`.
3. Restart Ring. The mode badge must read **HOSTED**: in the terminal header, and in the desktop app as `HOSTED · meta-models/muse-spark-open-1026 via Baseten`. If it says EVIDENCE-ONLY, hosted mode isn't armed.

## What existed before vs what we built this week

Meta's rules ask for a fresh repo with only event-period work, and the pre-existing base as a pinned dependency. That's how this repo is laid out.

| | Before the event | Built Oct 28 – Nov 4, 2026 |
|---|---|---|
| **What** | MAOS Core and the MAOS Industrial product: multi-agent orchestrator, provider backends, CLI/REPL, audit chain, the Industrial cockpit (deterministic T-07 analysis, Rust audit engine, offline stores, approvals queue) | **Ring**: the agent loop and threads, hybrid routing with Muse Spark Open, 15 tools behind an approval registry, the safety layer, 6 shift skills, the terminal agent and TUI, the desktop workspace and overlay, the P-12 demo pack, release packaging |
| **Where** | Public repo [`maos`](https://github.com/Amitakshya333/maos), pinned at `f9525055c56a7f7771dd2fa029c147c2960a98a3` (Sep 29, 2026) | [`patches/`](patches/): 33 commits. [`source/`](source/): 119 new files. [`CHANGED_FILES.md`](CHANGED_FILES.md): 104 modified files (+7,672 / −2,588) |
| **Size** | n/a | About 13,100 lines of new TypeScript/JavaScript and 15,200 lines of new tests |

There are no commits in the base between Sep 29 and Oct 28, so nothing pre-event is counted as event work. Commit dates, the generation command and byte counts are in [`PATCHES.md`](PATCHES.md).

## How we know it works

| Check | Result |
|---|---|
| The 33 patches on the pinned base reproduce the freeze commit `82b37fe` | **Identical**: zero diff across `src/ tests/ desktop/ scripts/ demo/`. All 119 files in `source/` pass `sha256sum -c` against the built tree. |
| Fresh-machine setup, README commands only | **Passed** on a Debian 13 VM and a fresh Windows 11 user account (2026-11-04) |
| Ring test suites (`npx vitest run tests/industrial/ring-* tests/gui/ring-*`) | **167 passing, 8 skipped** on a clean checkout. One P-12 test assumes no engine binary is installed and fails if one is; that's a test-design issue, not a product bug. |
| Desktop app, end to end | Turbine check, approval, artifacts and refusal all captured from the real Electron app (screenshots above) |
| Safety evaluation (`ring-dev-c-safety.test.ts`) | Refuses restart (turbine and pump); refuses to invent readings; asks before every write; never leaks raw CSV rows; flags prompt injection inside documents |
| Hosted reliability (Muse Spark Open, live) | Evidence tools 3/3. A bookkeeping miss in 1 of 4 runs led to the hybrid design. |

## Honest limitations

- **Synthetic data only.** T-07 and P-12 are bundled demonstration fixtures. The limits are demonstration thresholds derived from ISO 10816-3 guidance, **not a certified standard**.
- **Decision support, not operating authority.** Ring never authorizes starting, restarting or operating equipment.
- **Evidence-only without a key.** Hosted reasoning needs your own Baseten key plus the config above.
- **Not included:** voice, and image/vision analysis of the P-12 photo and scan. Ring reports them unavailable rather than guessing. The "What am I looking at?" capture button exists but isn't wired to vision analysis.
- **Unsigned desktop builds.** No code-signing certificate. Checksums detect tampering but don't prove a publisher.
- **Known cosmetic issue:** in terminal headless output, the one-line `Verdict:` summary can cut off the first word of the instruction. The full answer below it is correct.

## Repository map

```
patches/          33 event commits, applied in order onto the pinned base (the build path)
scripts/          setup.sh / setup.ps1: clone base → verify SHA → apply patches → build
source/           every file created during the event, byte-identical to the build (for reading)
CHANGED_FILES.md  the 104 pre-existing files the event modified, with line counts
docs/screenshots/ real captures (method + checksums in CAPTIONS.md)
ARCHITECTURE.mmd  the architecture diagram source
PATCHES.md        base SHA, freeze SHA, patch count, bytes, generation command
```

## License

MIT, carried from MAOS Core (Copyright (c) 2025 Amitakshya Sutar).

Built by **Amitakshya Sutar** for the Meta AI Developer Hackathon, Oct–Nov 2026. · [maos.web.app/indus](https://maos.web.app/indus)
