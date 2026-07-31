---
name: skyrim-mod-reworking
description: Orchestrate repair, modernization, compatibility work, or cleanup of an existing Skyrim mod while preserving
  behavior, save compatibility, ownership, and a reversible release history.
compatibility: Windows 10/11; Skyrim Special Edition or Anniversary Edition; PowerShell and Python 3 when bundled scripts
  are used
metadata:
  version: 4.3.0
  updated: '2026-07-22'
  library: overseer-skyrim-agent-skills
  provider: grok
  provider_pack_version: 1.0.0
  base_library: Skyrim-Agent-Skills-v6
  error_registry_revision: 4.3.0
  final_pack_version: 4.3.0
---

# Existing mod reworking

## Inspect before changing

1. Inventory plugin records, scripts, DLLs, runtime configs, assets, installer, and documentation.
2. Reproduce the reported defect from logs or static evidence.
3. Identify the original mod's public contracts: FormIDs, EditorIDs, script names, properties, events, config paths, and save data.
4. Locate all compatibility patches and optional dependency paths.
5. Create the next full-copy version.

## Classify each proposed change

- bug fix;
- migration to a runtime framework;
- dependency replacement;
- plugin record change;
- Papyrus state migration;
- native DLL change;
- asset repair;
- packaging-only change.

Load the matching specialist. Do not let this orchestrator become a second syntax manual.

## Preservation rules

- Never clean, compact, renumber, strip masters, or rebuild a source plugin without a specific proven need.
- Preserve FormIDs and persisted Papyrus property/state contracts whenever possible.
- Do not delete unknown data simply because a custom parser cannot understand it.
- Treat generated FaceGen, behavior, cache, and LOD output as derived artifacts with identifiable source.
- Compare old and new release trees and document every removed file.

## Validation

Reproduce the original failure, prove the fix, then run regression checks for the preserved behavior. Use `skyrim-ship-gate` last.

## Evidence standard

Use this hierarchy for version-sensitive facts:

1. The active project's `ENVIRONMENT.md`, `TASK.md`, installed framework version, and build files.
2. Official upstream documentation or source for that exact version.
3. Known-good files from the user's installed mod library, read-only.
4. Direct inspection of the relevant ESM, ESP, DLL, script, log, or archive.

Do not substitute memory, an old example, or a plausible token. Record the evidence path or URL in `VALIDATION.md`.

## Grok Build execution adapter

- Enter `/plan` before broad edits, architecture changes, plugin work, DLL work, or large generated configurations.
- For bulk output, generate and validate deterministic chunks rather than one giant hand-edited file.
- Subagents may research or review independently; one implementation owner merges changes.
- Use `/flush` before ending a consequential session and record unresolved work in project state files.
- Never convert speed, a clean parser pass, or a confident summary into a runtime-success claim.

### Skill-specific provider control

Diff against the last known-good release and explain every removed feature, file, record family, and installer option.

## Evidence-derived regression accounting

Maintain a defect and feature matrix across original, parent, active, and final artifacts. Separate inherited defects from regressions introduced by the current AI. Trace every README, MCM, and Nexus claim to implemented files and validation. Label prototypes, bootstraps, and approximations explicitly. Test the real user symptom before and after the rework.
