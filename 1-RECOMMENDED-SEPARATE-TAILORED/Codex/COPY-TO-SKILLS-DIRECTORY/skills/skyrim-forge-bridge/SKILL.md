---
name: skyrim-forge-bridge
description: Use the local Skyrim Forge Bridge for supported read-only inspection, health checks, scans, plan validation,
  and plugin-header summaries. Do not use it as an ESP writer in version 0.2.x.
compatibility: Windows 10/11; Skyrim Special Edition or Anniversary Edition; PowerShell and Python 3 when bundled scripts
  are used
metadata:
  version: 4.3.0
  updated: '2026-07-22'
  library: overseer-skyrim-agent-skills
  provider: codex
  provider_pack_version: 1.0.0
  base_library: Skyrim-Agent-Skills-v6
  error_registry_revision: 4.3.0
  final_pack_version: 4.3.0
---

# Skyrim Forge Bridge

## Resolve the local installation

Do not assume a personal installation path. Resolve it from one of these sources,
in order:

1. an explicit path supplied by the user;
2. a project-local tool manifest or configuration;
3. the `SKYRIM_FORGE_BRIDGE_ROOT` environment variable;
4. an executable already available on `PATH`.

Conceptual layout:

```text
<SKYRIM_FORGE_BRIDGE_ROOT>\
  .venv\Scripts\skyrim-forge.exe
```

Example using an environment variable:

```powershell
$BridgeExe = Join-Path $env:SKYRIM_FORGE_BRIDGE_ROOT '.venv\Scripts\skyrim-forge.exe'
& $BridgeExe health
```

Use `scan` and `plugin-header` only when they match the task. Capture output in
the active project's `REPORTS\forge-*.txt`.

## Capability boundary for 0.2.x

Supported use includes read-only inventory, header inspection, archive/project
scanning, structured-plan validation, and isolated workspace assistance.

It does not write ESP/ESL/ESM records, compact FormIDs, author VMAD, drive
Creation Kit, or replace semantic plugin validation. Trust the locally installed
`health` and capability output when version behavior differs.

## Fallback

If Forge Bridge is missing or fails, continue with the relevant specialist and
existing read-only tools. Do not invent a replacement scanner during an unrelated task.

## Report

```text
FORGE: version=... | health=ok|failed | commands=... | limitations=...
```

## Codex execution adapter

- Follow the active `AGENTS.md` instruction chain before this skill.
- Use a written plan for difficult or high-risk work, but keep the plan tied to executable gates.
- Delegate only independent exploration, research, or review. One owner edits a tightly coupled file set.
- Preserve a clean diff and request an independent verification pass before calling the artifact complete.
- Do not write custom files into Codex's native `memories` directory; durable Skyrim lessons belong in the provider registry.

### Skill-specific provider control

Use the bridge only for capabilities confirmed by its current health and capability response.
