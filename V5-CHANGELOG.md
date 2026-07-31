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
