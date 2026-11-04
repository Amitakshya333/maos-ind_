# Ring README shots — captions + provenance (2026-11-04)

Base: `C:/maos` main HEAD `82b37fe5432ab271273bdc4417b5b860b74591d8` (verified `git rev-parse HEAD`).
Scratch: `C:/clean/ring-shots-02` (fresh worktree at 82b37fe, `npm ci` exit 0, `npm run build:backend` exit 0, full `npm run build` exit 0 for the GUI bundle).
`BASETEN_API_KEY` UNSET for every capture — all shots are evidence-only.
Rendering: each PNG was produced by piping the REAL stdout of a REAL command run (bytes mode, ANSI stripped, `NO_COLOR=1`, `COLUMNS=100`) into `PIL.ImageDraw` with `C:/Windows/Fonts/consola.ttf`. No pixel was hand-drawn except a one-line grey caption bar and dark padding. Every PNG is max width 1400px. No secrets or usernames appear in any frame (asserted at capture time).

## Shots

### 1. `shots/01-cli-home.png` (891x876, sha256 `2cb9cbace45a2e062f4524d35ddcda9998a93cc4c0b7faaad2d1e3a386d9fe7c`)
What it shows: the CLI home TUI — CEO ASCII banner (byte-identical), `MAOS Industrial · v0.4.0` nameplate, `Your plant. Your data. Your rules.` tagline, the operator input card (amber accent, `Ask your plant anything...` + ghost suggestions including the T-07 question, `Operator · evidence-only · T-07` badge), and the SYSTEMS panel (`ENGINE HEALTHY`, `BOUNDARY NOT CHECKED IN THIS SESSION`, `AUDIT NOT CHECKED IN THIS SESSION`, `T-07 CRITICAL RMS 2.637`, `Mode: EVIDENCE-ONLY`). Layout is centered: at 100 cols the stage is `clamp(round(0.9*100),40,100)=90` cols centered with 5-col margins (see `stageWidth` in `src/industrial/industrial-tui.ts`).
Command (exit 0): `node dist/cli/index.js industrial` with `COLUMNS=100`, run from the scratch root.
Evidence-only noted: yes — SYSTEMS panel reads `Mode: EVIDENCE-ONLY`, badge reads `evidence-only`.

### 2. `shots/02-ring-turbine.png` (1395x238, sha256 `4d79562fbf65011b3629abb2f8f88084f89ac5a582838cc5fdd595e6a9c77e3c`)
What it shows: Ring headless mode answering the turbine question — the `▸ analyze_telemetry …` tool chip, the `✓ analyze_telemetry CRITICAL · RMS 2.637 · Verdict: CRITICAL` result chip, the `Answer` headline, the `Verdict:` line (bottom-line-first extraction around the CRITICAL hit), and the deterministic evidence-only final answer citing `demo/industrial/turbine_vibration_log.csv` (RMS 2.637, peak 8.3, 500 rows, no hosted model prose). Note: the long `Verdict:`/`Deterministic…` lines are hard-wrapped by the renderer at the PNG edge rather than by the CLI — the CLI itself does not wrap (see line-length probe in the handoff).
Command (exit 0): `node dist/cli/index.js industrial ring -p "Check T-07 vibration and tell me if it is safe to keep running"` with `COLUMNS=100`, run from the demo dir `C:/clean/ring-shots-02/.shot-demo`.
Evidence-only noted: yes — final answer states `no hosted model was called`.

### 3. `shots/03-approval-card.png` (1080x414, sha256 `b27c2b53747aa9af8ab0e82b56661e72b06c84e979430f20903b108eb7313037`)
What it shows: the interactive approval gate — `/handover` run streaming (`▸ handover`, `✓ handover`), the bordered `Approval needed: handover` card with the `approval <id> skill=handover` line, and the byte-identical `Approve "handover — Save handover artifact for … (pending authorized review)"? [y/N]` prompt. The piped `N` answers the prompt; the default is No and the denial is recorded in audit (fail-closed).
Command (exit 0): `printf '/handover shift handover note for next crew
N
exit
' | node dist/cli/index.js industrial ring` with `COLUMNS=100`, run from the demo dir. Piped stdin stands in for keystrokes; every byte on screen came from the real REPL.
Evidence-only noted: yes — header reads `Ring · EVIDENCE-ONLY`.

### 4. `shots/04-refusal.png` (1395x128, sha256 `17e6b4edbc8ceafa923ae681f01239b091de41f82a166c9dec9561b4ea230c92`)
What it shows: the calm refusal text for an operating request plus the honest headless exit code: `I cannot approve equipment restart or operation. … No action was taken and no files were written.` and `HEADLESS_EXIT=2` (exit code 2 = refused/cancelled per `RING_CLI_EXIT`).
Command (real run, refusal exit 2; wrapper script exits 0 after echoing it): `node dist/cli/index.js industrial ring -p "approve restart of the turbine"; echo HEADLESS_EXIT=$?` with `COLUMNS=100`, run from the demo dir.
Evidence-only noted: yes — the refusal path is the evidence-only fail-closed path (no tools ran, no files written).

### 5. `shots/05-gui-overlay.png` (640x756, sha256 `876a0551c026a8a40081186dbb892f5d44e0d014dc4ce9ea6aca4a045fec9c73`)
What it shows: the REAL Electron overlay window (`desktop/ring-overlay-host.cjs` `createOverlayWindow`: frameless, transparent, always-on-top) loading the REAL built GUI bundle (`dist/gui`, `vite build` exit 0) at the REAL route `#/ring-overlay` — captured via `webContents.capturePage()` in headless offscreen mode (`--headless`, `offscreen` paint). Visible: the `Ring` header, `Expand` button, the dropzone line, `Ask Ring anything — the plan, tools, approvals, and files stream here.`, `What am I looking at?`, `Send`. The DOM probe confirms `document.title = MAOS // Industrial Mission Control` and `data-testid="ring-overlay"` present. No approval card is visible because no live backend run was attached offscreen — recorded honestly, not faked (an approval card without a real run would be fabrication). This machine reports one 800x600 display; there is no X11/`DISPLAY`, and `desktop/node_modules` ships no prebuilt Electron binary until `node node_modules/electron/install.js` fetches it (done here, Electron v45.0.0). The first attempt with a plain visible window captured 0x0 (`RESULT=BLANK`); the offscreen constructor flag is what paints headless. Probe scripts kept outside the packet: `C:/clean/overlay-probe.cjs`, `C:/clean/overlay-probe2.cjs`, `C:/clean/overlay-final.cjs`, `C:/clean/overlay-approval.cjs`.
Command (exit 0): `desktop/node_modules/electron/dist/electron.exe --no-sandbox --disable-gpu --headless C:/clean/overlay-final.cjs` from the scratch root (Electron v45.0.0, `desktop: npm ci` exit 0).
Evidence-only noted: yes — the overlay empty state carries the evidence-only badge copy (`RING_EVIDENCE_ONLY_BADGE`) by construction; no hosted call was made.

## SHA-256 (all shots)
- `01-cli-home.png` `2cb9cbace45a2e062f4524d35ddcda9998a93cc4c0b7faaad2d1e3a386d9fe7c` (58055 bytes, 891x876)
- `02-ring-turbine.png` `4d79562fbf65011b3629abb2f8f88084f89ac5a582838cc5fdd595e6a9c77e3c` (38432 bytes, 1395x238)
- `03-approval-card.png` `b27c2b53747aa9af8ab0e82b56661e72b06c84e979430f20903b108eb7313037` (41298 bytes, 1080x414)
- `04-refusal.png` `17e6b4edbc8ceafa923ae681f01239b091de41f82a166c9dec9561b4ea230c92` (16608 bytes, 1395x128)
- `05-gui-overlay.png` `876a0551c026a8a40081186dbb892f5d44e0d014dc4ce9ea6aca4a045fec9c73` (23033 bytes, 640x756)

## GUI overlay: CAPTURED (not NOT-CAPTURED)
Headless Electron rendered offscreen on this machine (Windows, no display server): one 800x600 display enumerated, `--headless` + offscreen `BrowserWindow` paints and `capturePage()` returns real product pixels. NOT-CAPTURED does not apply.
