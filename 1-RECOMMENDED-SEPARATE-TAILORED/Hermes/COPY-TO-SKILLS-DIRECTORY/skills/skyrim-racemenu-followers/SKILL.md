---
name: skyrim-racemenu-followers
description: Build or repair a shareable Skyrim follower from a RaceMenu or CharGen preset, including plugin records, FaceGen,
  head parts, tint, body assets, voice, recruitment, and skin-normal compatibility.
compatibility: Windows 10/11; Skyrim Special Edition or Anniversary Edition; PowerShell and Python 3 when bundled scripts
  are used
metadata:
  version: 4.3.0
  updated: '2026-07-22'
  library: overseer-skyrim-agent-skills
  provider: hermes
  provider_pack_version: 1.0.0
  base_library: Skyrim-Agent-Skills-v6
  error_registry_revision: 4.3.0
  final_pack_version: 4.3.0
---

# RaceMenu follower workflow

## Inputs

- Preset and sculpt data.
- Race, sex, weight, height, voice, combat style, class, outfit, and follower behavior.
- Body, skin, hair, eye, brow, and head-part dependencies.
- Redistribution permissions.

## Workflow

1. Freeze the asset and dependency plan before plugin authoring.
2. Create NPC, race/head-part, outfit, faction, relationship, package, and voice records through `skyrim-plugin-authoring`.
3. Generate FaceGen using a verified authoring path. Do not fake FaceGen by copying unrelated meshes.
4. Match weight, tint, head mesh, face normal, body normal, and skin texture sets.
5. Check dynamic normal-map or skin frameworks for post-load overrides when a match briefly appears then changes.
6. Add recruitment and dismissal through the smallest compatible framework or dialogue path.
7. Verify loose-file paths, archive layout, masters, and optional asset conditions.
8. Test dark-face, neck seam, expression, blinking, inventory, combat, dismissal, and save reload.

Do not ship presets or third-party assets without permission.

## Evidence standard

Use this hierarchy for version-sensitive facts:

1. The active project's `ENVIRONMENT.md`, `TASK.md`, installed framework version, and build files.
2. Official upstream documentation or source for that exact version.
3. Known-good files from the user's installed mod library, read-only.
4. Direct inspection of the relevant ESM, ESP, DLL, script, log, or archive.

Do not substitute memory, an old example, or a plausible token. Record the evidence path or URL in `VALIDATION.md`.

## Hermes execution adapter

- Load this skill on demand through progressive disclosure; do not preload the entire Skyrim library.
- Treat installed provider skills as curated, read-only workflows. Write proposed improvements to `MEMORY/CANDIDATES.md` instead of silently rewriting them.
- Keep project instructions in workspace `AGENTS.md`. Keep identity and tone in `SOUL.md`.
- Resolve the active `HERMES_HOME` or profile before reading or writing provider memory.
- Store only evidence-scored lessons in the Skyrim registry; do not contaminate native Hermes memory with unverified completion claims.

### Skill-specific provider control

Test appearance across summon order, actor 3D readiness, save/reload, reset, and dynamic body/normal-map systems.

## Evidence-derived follower asset and lifecycle controls

- Detect dependencies by exact plugin name and active plugin set, not substrings or profile timestamps.
- Inspect BSA/BA2 archives and mod-manager virtual/deployed files; loose-file absence is not asset absence.
- Verify the actual face-tint/texture slot instead of assuming slot zero.
- Test dynamic body, skin, normal-map, OBody/preset, and appearance systems reapplying after actor 3D loads, summon order, reset, outfit change, and save reload.
