---
name: skyrim-voiced-dialogue
description: Create or repair Skyrim dialogue and voice assets, including DIAL/INFO records, quest/topic conditions, voice-type
  paths, WAV/XWM/FUZ/LIP generation, silent fallback, and revoice workflows.
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

# Voiced dialogue

## Inputs

- Exact dialogue text and speaker records.
- Quest, topic, INFO, conditions, voice types, and response order.
- Voice-generation tool and model permissions.
- Target audio format and subtitle policy.

## Workflow

1. Author dialogue records with `skyrim-plugin-authoring` and scripts with `skyrim-papyrus-modding`.
2. Resolve the final voice folder from the plugin name and voice type.
3. Generate normalized source audio, then the required XWM/FUZ and LIP assets using pinned tools.
4. Keep line IDs and filenames deterministic.
5. Verify every INFO has the intended conditions, flags, response text, and audio path.
6. Provide a silent voice fallback when the design requires subtitle timing.
7. Check conversation flow, interruption, priority, repeated lines, and save reload.
8. Document synthetic voice provenance and permissions.

A valid audio file does not prove the INFO record or path is correct.

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

Validate quest/topic conditions, voice-type paths, generated audio formats, and fallback behavior together.
