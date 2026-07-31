---
name: mantella-config
description: Edit, merge, or diagnose Mantella configuration, prompts, conversation flow, TTS integration, and source changes
  while preserving user settings and secrets.
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

# Mantella configuration and source

## Inputs

- Exact Mantella version and installation type.
- Current config, prior config, logs, source revision, and desired behavior.
- LLM and TTS provider contract without exposing secrets.

## Workflow

1. Back up the current config and redact credentials from reports.
2. Diff old and new schemas by key, section, default, type, and deprecation.
3. Preserve user values only where the new schema still supports them.
4. Keep prompt changes separate from transport, TTS, interruption, and Papyrus changes.
5. Validate config parsing and start the narrowest component possible.
6. For source edits, map the conversation lifecycle and cancellation/interruption paths before changing code.
7. Test start, normal response, interruption, timeout, TTS failure, provider failure, and shutdown.
8. Document any setting that must be re-entered manually.

## Context efficiency

Do not load entire voice-model folders or conversation histories. Use the failing config, relevant source modules, and bounded logs.

## Evidence standard

Use this hierarchy for version-sensitive facts:

1. The active project's `ENVIRONMENT.md`, `TASK.md`, installed framework version, and build files.
2. Official upstream documentation or source for that exact version.
3. Known-good files from the user's installed mod library, read-only.
4. Direct inspection of the relevant ESM, ESP, DLL, script, log, or archive.

Do not substitute memory, an old example, or a plausible token. Record the evidence path or URL in `VALIDATION.md`.

## Codex execution adapter

- Follow the active `AGENTS.md` instruction chain before this skill.
- Use a written plan for difficult or high-risk work, but keep the plan tied to executable gates.
- Delegate only independent exploration, research, or review. One owner edits a tightly coupled file set.
- Preserve a clean diff and request an independent verification pass before calling the artifact complete.
- Do not write custom files into Codex's native `memories` directory; durable Skyrim lessons belong in the provider registry.

### Skill-specific provider control

Preserve user secrets and local settings; separate configuration compatibility from source-code changes.
