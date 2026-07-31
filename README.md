# Skyrim AI FINAL MANUAL INSTALL v5.0.0

All-in-one portable toolkit for AI-assisted Skyrim SE/AE modding.

Installs provider skill packs (Claude, Codex, Grok, Kimi, Hermes), wires MCP tools, and bundles offline installers for the current AI/Skyrim tooling stack.

## Quick start

**Windows**

1. Clone or download this repo.
2. Double-click `INSTALL-V5-AIO.bat`, or run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\INSTALL-V5-AIO.ps1
```

3. Fully restart your AI app(s).

### Common options

```powershell
.\INSTALL-V5-AIO.ps1 -Providers Grok,Claude
.\INSTALL-V5-AIO.ps1 -Mode OnlineLatest
.\INSTALL-V5-AIO.ps1 -SkillsOnly
.\INSTALL-V5-AIO.ps1 -ToolsOnly
.\INSTALL-V5-AIO.ps1 -WorkspaceRoot "D:\My\AI-Workspace"
```

| Mode | Behavior |
|------|----------|
| `BundledFirst` (default) | Use `BUNDLED-TOOLS\offline`, fall back to GitHub |
| `OnlineLatest` | Always fetch latest GitHub releases |
| `BundledOnly` | Offline zips only (no network) |

## What gets installed

- **Provider skills** — ~82 skills per AI (Claude, Codex, Grok, Kimi, Hermes)
- **houseCARL** MCP + MO2 instance or Vortex shim setup
- **Spooky's AutoMod Toolkit**
- **codebase-memory-mcp**
- **Headroom** (context compression)
- **Superpowers** + **Ponytail** plugins/skills
- **CodeBurn** (optional, via npm/npx)
- Grok MCP wiring + portable tool discovery

### Not bundled

**Skyrim Forge** is not redistributed. Install it yourself and set `SKYRIM_FORGE_ROOT`, or place `INSTALLATION.json` beside the `skyrim-forge` skill.

## Update tools later

```powershell
.\TOOLS\Update-From-GitHub.ps1
.\TOOLS\Update-From-GitHub.ps1 -Components housecarl,codebase-memory -UpdateCatalogOffline
.\TOOLS\Ensure-Tools.ps1
.\TOOLS\Setup-HouseCarl.ps1
```

## Layout

```text
1-RECOMMENDED-SEPARATE-TAILORED/   per-AI tailored skill trees
2-OPTIONAL-SHARED-GENERIC/         shared generic trees
BUNDLED-TOOLS/offline/             shipped tool zips/wheels
BUNDLED-TOOLS/plugins/             Superpowers + Ponytail
BUNDLED-TOOLS/CATALOG.json         component registry
COPY-TO-YOUR-WORKSPACE/
TOOLS/                             installers and discovery scripts
_V5-CANONICAL-SKILLS/              maintainer master skills
INSTALL-V5-AIO.ps1 / .bat          master installer
START-HERE.txt                     short human guide
```

## Docs

- [START-HERE.txt](START-HERE.txt)
- [V5-AIO-GUIDE.md](V5-AIO-GUIDE.md)
- [V5-CHANGELOG.md](V5-CHANGELOG.md)
- [V5-INTEGRATION-AUDIT.md](V5-INTEGRATION-AUDIT.md)
- [BUNDLED-TOOLS/THIRD-PARTY-NOTICES.md](BUNDLED-TOOLS/THIRD-PARTY-NOTICES.md)
- [WHICH-AI-SHOULD-I-USE-FOR-SKYRIM.md](WHICH-AI-SHOULD-I-USE-FOR-SKYRIM.md)

## AI contract

Skills teach **portable discovery**. Paths are resolved from env vars, `LOCALAPPDATA`, and `PATH` — never hardcoded drive letters or usernames.

If a tool is missing, the AI should recommend `INSTALL-V5-AIO.ps1`, `Ensure-Tools.ps1`, or `Update-From-GitHub.ps1` — not invent paths or fake MCP results.

## Third-party components

Bundled offline artifacts and plugins retain their upstream licenses. See [BUNDLED-TOOLS/THIRD-PARTY-NOTICES.md](BUNDLED-TOOLS/THIRD-PARTY-NOTICES.md).

Notable upstream projects:

| Component | Upstream |
|-----------|----------|
| houseCARL | https://github.com/Avick3110/houseCARL |
| Spooky's AutoMod Toolkit | https://github.com/SpookyPirate/spookys-automod-toolkit |
| codebase-memory-mcp | https://github.com/DeusData/codebase-memory-mcp |
| Headroom | https://github.com/headroomlabs-ai/headroom |
| Superpowers | https://github.com/obra/superpowers |
| Ponytail | https://github.com/DietrichGebert/ponytail |
| CodeBurn | https://github.com/getagentseal/codeburn |

Do not re-upload third-party binaries to Nexus as your own work. Keep attribution. Prefer `TOOLS\Update-From-GitHub.ps1` for newer versions.

## Version

**v5.0.0** — based on `Skyrim-AI-FINAL-MANUAL-INSTALL-v4.3.0`

## License

Pack documentation and original installer scripts are provided as-is for personal and community use. Third-party tools inside `BUNDLED-TOOLS` keep their own licenses (see notices file).
