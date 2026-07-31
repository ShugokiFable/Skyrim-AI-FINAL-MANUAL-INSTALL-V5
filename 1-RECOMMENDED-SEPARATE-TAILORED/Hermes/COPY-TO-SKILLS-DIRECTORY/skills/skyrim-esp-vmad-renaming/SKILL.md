---
name: skyrim-esp-vmad-renaming
description: Perform a narrowly scoped rename of script, property, or string data inside Skyrim plugin VMAD while preserving
  binary structure. Use only when typed record editing is unavailable and the rename is fully verified.
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

# VMAD renaming

## Preferred path

Use a typed plugin library that understands the target VMAD record family. Reload and compare the result.

## Binary fallback

Raw byte replacement is allowed only when all conditions hold:

- the exact target string and owning record are identified;
- the encoding and length prefix are understood;
- every occurrence is classified;
- the transform updates lengths and enclosing record sizes correctly, or the replacement is exactly the same byte length;
- a parser can walk the complete file before and after;
- a byte diff shows no unrelated changes;
- the original remains untouched.

Do not use global `bytes.replace` on a plugin. Do not rename a script without also shipping the corresponding PSC/PEX and preserving property contracts.

## Validation

1. Audit plugin structure before the change.
2. Extract the target record and VMAD tree.
3. Apply the transform to a workspace copy.
4. Reparse the complete plugin.
5. Compare masters, FormIDs, record sizes, VMAD scripts, properties, and unrelated bytes.
6. Compile renamed scripts and run the ship gate.

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

Require byte-length invariance or a typed writer; never improvise VMAD offsets.
