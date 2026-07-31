---
name: headroom
description: Use Headroom for on-demand context compression, retrieval by hash, and session stats via MCP. Recommend install when missing. Not a Skyrim record editor.
metadata:
  version: 5.0.0
  final_pack_version: 5.0.0
  upstream: https://github.com/headroomlabs-ai/headroom
---

# Headroom

Headroom saves context window by compressing large tool outputs and retrieving originals later.

Upstream: https://github.com/headroomlabs-ai/headroom

## Resolve

1. MCP tools present in session (`headroom_compress`, `headroom_retrieve`, …) → use them
2. Else CLI: `headroom --help` / `$env:HEADROOM_CMD`
3. Else recommend install

## Install recommendation

```text
pip install "headroom-ai[mcp]"     # tools only
pip install "headroom-ai[proxy]"   # proxy + tools
headroom mcp install               # where supported (e.g. Claude Code)
```

Optional full-traffic proxy:

```text
headroom proxy
# point the AI app base URL at the local proxy per Headroom docs
```

## When to use

- Huge logs, greps, JSON dumps, crash stacks before reasoning
- Need original later → keep the returned `hash` and `headroom_retrieve`

## When not to use

- Tiny snippets
- Replacing Skyrim domain skills
- Fabricating compression when MCP is down — just summarize carefully instead

## Multi-provider

Works with any MCP host (Claude, Cursor, Codex, Grok, …) once the server is registered. If registration fails, say so and continue without Headroom.

## Grok-specific (required for auto-compress)

MCP tools alone are helpers. **Grok traffic compression needs the proxy route**
(`GROK_MODELS_BASE_URL` -> `http://127.0.0.1:8787/...`).

**Fresh V5 AIO install applies durable wrap automatically** when the Grok
provider is selected. That is the same shape as a working machine:

1. `headroom install apply --providers manual --target grok_build`
2. User env `GROK_MODELS_BASE_URL` / `GROK_MODEL_GROK_BUILD_BASE_URL` -> `:8787/v1`
3. `headroom install start` (persistent proxy)
4. `[mcp_servers.headroom]` in `~/.grok/config.toml`

Pack helper (idempotent; does not kill a healthy proxy or live wrap):

```text
.\TOOLS\Ensure-Headroom-Grok.ps1
.\TOOLS\Ensure-Headroom-Grok.ps1 -CheckOnly
```

Optional session launch:

```text
headroom wrap grok
headroom wrap grok-build
```

Verify:

```text
headroom install status
# User env GROK_MODELS_BASE_URL should point at 127.0.0.1:8787
# Proxy /readyz should be healthy
```

Do not tell users "MCP is enough" for Grok auto-compress.