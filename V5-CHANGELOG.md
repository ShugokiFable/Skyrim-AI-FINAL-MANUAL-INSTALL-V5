# V5.0.0 changelog

Date: 2026-07-31  
Base: Skyrim-AI-FINAL-MANUAL-INSTALL-v4.3.0

## Goals

1. Integrate new AI/Skyrim tools into the skill pack for every supported provider.
2. Keep paths portable: discover tools or recommend install — never require the pack author's drive letters.
3. Preserve V4.3 registry, validators, and safety laws.

## Added skill families

### houseCARL ecosystem
- `housecarl` (multi-provider discovery + MCP notes)
- `mutagen-reference`, `papyrus-reference`, `papyrus-optimization`
- `spid-authoring`, `kid-authoring`, `skypatcher-authoring`, `oar-authoring`
- `dialogue-authoring`, `facegen-diagnostics`, `biped-slot-reference`
- `bulk-record-jobs`, `skse-plugin-authoring`, `tool-output-awareness`

### Spooky's AutoMod Toolkit
- `spookys-automod-toolkit` (root + references from toolkit docs)
- Module skills: `skyrim-esp`, `skyrim-papyrus`, `skyrim-mcm`, `skyrim-nif`, `skyrim-archive`, `skyrim-audio`, `skyrim-skse`

### AI coding utilities
- `codebase-memory` (DeusData MCP + Grok wiring notes)
- `headroom` (context compression MCP)
- `using-superpowers` + Superpowers process skills (brainstorming, systematic-debugging, TDD, plans, verification, …)
- `ponytail` + ponytail-review/audit/debt/gain/help
- `codeburn` (local token/cost analytics)

### Pack orchestration
- `ai-tooling-stack` — when to use which tool
- `tool-discovery` + `scripts/discover_tools.ps1`
- `skyrim-forge` refreshed from live skill (no machine-specific INSTALLATION.json shipped)

## Pack root additions

- `TOOLS/discover_tools.ps1`
- `TOOLS/Fix-Grok-Codebase-Memory-Direct.ps1` (portable; discovers exe)
- `TOOLS/MCP-CONFIG-EXAMPLES.toml.txt`
- `TOOLS/RECOMMENDED-INSTALLS.md`
- `_V5-CANONICAL-SKILLS/` master tree used to fan out to providers
- `V5-CHANGELOG.md`, `V5-INTEGRATION-AUDIT.md`

## Router / instructions

- `skyrim-tool-router` rewritten for V5 routes (houseCARL, Spooky, MCP utils).
- All `AGENTS.md` / `CLAUDE.md` gain **V5 tooling laws**.
- `START-HERE.txt`, `WINDOWS-PATH-MAP.md` updated.
- Provider `COPY-MAP.md` files note MCP + discovery steps.

## Counts

- V4.3 tailored skills per provider: **34**
- V5 skills per provider: **~82**
- Provider skill roots updated: **10** (5 tailored + 5 generic)

## Non-goals / intentional limits

- Does not redistribute houseCARL or Spooky **binaries** (licensing + size); skills + install guidance only.
- Does not embed Bethesda script headers.
- Does not assume MO2 path; user must set instance.
- Superpowers/Ponytail plugins remain optional; markdown skills work standalone.
- CodeBurn is optional analytics, not a mod compiler.

## Upgrade from v4.3.0

1. Keep v4.3 folder as backup.
2. Copy V5 provider skills over the old skills directory (overwrite).
3. Refresh workspace `AGENTS.md` / `CLAUDE.md`.
4. Run `TOOLS\discover_tools.ps1` and install anything you want from MISSING.
5. Re-register MCP servers; fully restart each AI app.

## V5.0.0 add-on — houseCARL auto setup

- `TOOLS\Setup-HouseCarl.ps1` — one-shot MO2 detection or Vortex shim build
- `TOOLS\housecarl\houseCARL-Vortex-shim-setup.pdf` — shim design reference
- `TOOLS\housecarl\README.md` — operator guide
- `housecarl\scripts\Setup-HouseCarl.ps1` copied into every provider skill tree
- Env + Grok MCP wiring + `%LOCALAPPDATA%\houseCARL-data\v5-setup-state.json`
- `discover_tools.ps1` reports `housecarl-instance` (MO2-INSTANCE | VORTEX-SHIM)

## V5.0.0 AIO layer

- `INSTALL-V5-AIO.ps1` / `INSTALL-V5-AIO.bat` — one-shot skills + tools + MCP + houseCARL setup
- `BUNDLED-TOOLS\offline\` — houseCARL, Spooky, codebase-memory, Headroom wheel, Superpowers, Ponytail
- `BUNDLED-TOOLS\plugins\` — ready Superpowers + Ponytail trees
- `BUNDLED-TOOLS\CATALOG.json` — GitHub repos + install rules
- `TOOLS\Update-From-GitHub.ps1` — releases/latest fetch
- `TOOLS\Ensure-Tools.ps1` — agent/user repair helper
- `TOOLS\V5-Common.ps1` — shared installer library
- `V5-AIO-GUIDE.md` — user + AI contract

## v5.0.0 post-publish hotfix (codebase-memory safety)

Date: 2026-07-31

### What went wrong
The AIO installer used `robocopy` to force-extract `codebase-memory-mcp` into
`%LOCALAPPDATA%\Programs\codebase-memory-mcp` even when the MCP was already
installed and running. A locked binary + aggressive MCP rewires could break
Grok/Codex/Claude wiring and force a manual reinstall + `Fix-Grok-Codebase-Memory-Direct.ps1`.

### Fixes in this pack
1. **Keep existing install**: if `codebase-memory-mcp.exe` is already discoverable
   (prefer `Programs\codebase-memory-mcp\`), the installer **does not overwrite** it.
2. **Locked-file guard**: `Copy-V5RoboSafe` / `Test-V5FileLocked` refuse to replace
   a running MCP binary.
3. **Grok MCP upsert is idempotent**: `-SkipIfPresent` leaves a correct
   `codebase-memory-mcp` (and other) block alone so housecarl/headroom/forge are
   not stripped by a partial rewrite.
4. **Canonical path**: wire always prefers
   `%LOCALAPPDATA%\Programs\codebase-memory-mcp\codebase-memory-mcp.exe`
   over any `.local\bin` shim.
5. **Fix-Grok script**: same prefer-Programs + no-touch-if-correct behavior.

### Manual recovery (if CBM is broken again)
```powershell
cd "$env:LOCALAPPDATA\Programs\codebase-memory-mcp"
# follow Install.txt / install.ps1 --ui
powershell -ExecutionPolicy Bypass -File .\Fix-Grok-Codebase-Memory-Direct.ps1
```
Then fully restart Grok and confirm `/mcp` shows codebase-memory-mcp.

## v5.0.1 Codebase-memory safety hotfix

Date: 2026-07-31

### Problem
The AIO installer used robocopy to force-extract codebase-memory-mcp into
`%LOCALAPPDATA%\Programs\codebase-memory-mcp` even when MCP was already
installed and running. A locked binary plus aggressive MCP rewires could
break Grok/Codex/Claude wiring and force manual reinstall +
`Fix-Grok-Codebase-Memory-Direct.ps1`.

### Fixes
1. **Keep existing install**: if `codebase-memory-mcp.exe` is already
   discoverable (prefer `Programs\codebase-memory-mcp\`), installer does not overwrite it.
2. **Locked-file guard**: `Copy-V5RoboSafe` / `Test-V5FileLocked` refuse to replace a running MCP binary.
3. **Grok MCP upsert is idempotent**: `-SkipIfPresent` leaves a correct
   `codebase-memory-mcp` (and other) block alone so housecarl/headroom/forge
   are not stripped by a partial rewrite.
4. **Canonical path**: wire always prefers
   `%LOCALAPPDATA%\Programs\codebase-memory-mcp\codebase-memory-mcp.exe`
   over any `.local\bin` shim.
5. **Fix-Grok script**: same prefer-Programs + no-touch-if-correct behavior.

### Manual recovery (if CBM broken again)
```powershell
cd "$env:LOCALAPPDATA\Programs\codebase-memory-mcp"
# follow Install.txt / install.ps1 --ui
powershell -ExecutionPolicy Bypass -File .\Fix-Grok-Codebase-Memory-Direct.ps1
```
Then fully restart Grok and confirm `/mcp` shows codebase-memory-mcp.


## v5.0.2 Headroom Grok durable wrap (APPLY on install)

Date: 2026-07-31

### Problem
For Grok, Headroom **MCP** (`headroom_compress` / `retrieve` / `stats`) is not enough.
Automatic context compression requires Grok **API traffic** to route through the
Headroom **proxy** (`GROK_MODELS_BASE_URL` -> `http://127.0.0.1:8787/...`).

Earlier AIO only **checked** wrap / optionally started an existing deploy.
A **fresh** machine did **not** get durable wrap the way a working author
machine does after `headroom install apply` + live proxy.

### Fix (fresh install now wraps Grok)
`INSTALL-V5-AIO.ps1` (Grok provider, default) runs `TOOLS\Ensure-Headroom-Grok.ps1`
which **applies**:

1. `headroom install apply --preset persistent-task --providers manual --target grok_build`
2. User env `GROK_MODELS_BASE_URL` and `GROK_MODEL_GROK_BUILD_BASE_URL` -> `http://127.0.0.1:8787/v1` (if unset)
3. `headroom install start` when proxy is down
4. Idempotent `[mcp_servers.headroom]` in `%USERPROFILE%\.grok\config.toml`

Idempotent on already-wrapped machines: skips apply when deploy targets already
include `grok` / `grok_build`; never kills a healthy proxy or live wrap session.

### Manual
```powershell
.\TOOLS\Ensure-Headroom-Grok.ps1
.\TOOLS\Ensure-Headroom-Grok.ps1 -CheckOnly
```

### Still separate
codebase-memory binary path stays `%LOCALAPPDATA%\Programs\codebase-memory-mcp\`
(see v5.0.1). Headroom wrap does not replace CBM; both are required for
"codebase works under Grok with compression."

