# Ensure-Headroom-Grok.ps1
# Fresh V5 install MUST leave Grok traffic routed through Headroom the same way a
# working author machine does. MCP alone is NOT enough.
#
# Two pieces:
#   1) Durable traffic wrap/proxy
#        headroom install apply --providers manual --target grok_build
#        + User env GROK_MODELS_BASE_URL / GROK_MODEL_GROK_BUILD_BASE_URL -> :8787
#        + headroom install start (persistent proxy)
#   2) MCP retrieve tools
#        [mcp_servers.headroom] in %USERPROFILE%\.grok\config.toml
#
# Safe defaults:
#   - Does not kill a healthy running proxy or live wrap session
#   - Idempotent: skips install apply when deploy already targets grok/grok_build
#   - Never touches codebase-memory binaries

param(
  [int]$Port = 8787,
  [switch]$SkipMcp,
  [switch]$SkipApply,
  [switch]$CheckOnly,
  [switch]$StartProxyIfDown
)

$ErrorActionPreference = 'Continue'
function Ok($m){ Write-Host "  OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  !!  $m" -ForegroundColor Yellow }
function Bad($m){ Write-Host "  XX  $m" -ForegroundColor Red }
function Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }

function Find-HeadroomExe {
  if ($env:HEADROOM_CMD -and (Test-Path -LiteralPath $env:HEADROOM_CMD)) { return $env:HEADROOM_CMD }
  $cands = @(
    (Join-Path $env:USERPROFILE '.local\bin\headroom.exe'),
    (Join-Path $env:USERPROFILE '.local\bin\headroom.EXE')
  )
  try { $g = (Get-Command headroom -EA SilentlyContinue).Source; if ($g) { $cands = @($g) + $cands } } catch {}
  foreach ($c in $cands) {
    if ($c -and (Test-Path -LiteralPath $c)) { return (Resolve-Path -LiteralPath $c).Path }
  }
  return $null
}

function Test-HeadroomProxy([int]$P) {
  foreach ($path in @('/readyz', '/health')) {
    try {
      $r = Invoke-WebRequest -Uri ("http://127.0.0.1:{0}{1}" -f $P, $path) -UseBasicParsing -TimeoutSec 3
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) { return $true }
    } catch {}
  }
  return $false
}

function Test-GrokWrapRunning {
  $hits = Get-CimInstance Win32_Process -EA SilentlyContinue |
    Where-Object { $_.CommandLine -and ($_.CommandLine -match 'headroom.*wrap\s+grok') }
  return [bool]$hits
}

function Get-HeadroomManifest {
  $manifest = Join-Path $env:USERPROFILE '.headroom\deploy\default\manifest.json'
  if (-not (Test-Path -LiteralPath $manifest)) { return $null }
  try {
    return Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
  } catch { return $null }
}

function Test-GrokDeployTargets($manifest) {
  if (-not $manifest -or -not $manifest.targets) { return $false }
  $t = @($manifest.targets | ForEach-Object { "$_".ToLowerInvariant() })
  return ($t -contains 'grok_build') -or ($t -contains 'grok')
}

function Get-GrokBaseUrl {
  $p = $env:GROK_MODELS_BASE_URL
  if ($p) { return $p }
  $u = [Environment]::GetEnvironmentVariable('GROK_MODELS_BASE_URL', 'User')
  if ($u) { return $u }
  $b = [Environment]::GetEnvironmentVariable('GROK_MODEL_GROK_BUILD_BASE_URL', 'User')
  if ($b) { return $b }
  return $null
}

function Set-UserEnvIfMissing([string]$Name, [string]$Value) {
  $cur = [Environment]::GetEnvironmentVariable($Name, 'User')
  if ($cur -and $cur.Trim().Length -gt 0) {
    if ($cur -match '127\.0\.0\.1|localhost') {
      Ok ("User env $Name already routes via Headroom: $cur")
      return $false
    }
    Warn ("User env $Name already set to non-local value; leaving alone: $cur")
    return $false
  }
  [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
  Set-Item -Path "Env:$Name" -Value $Value -EA SilentlyContinue
  Ok ("Set User env $Name = $Value")
  return $true
}

function Invoke-HeadroomApply([string]$Hr, [int]$P) {
  Step 'Applying durable Headroom deploy for Grok Build (fresh-install wrap)'
  # install apply target list only includes grok_build (not bare "grok").
  # That still sets GROK_MODEL_GROK_BUILD_BASE_URL and starts the shared proxy.
  # We also set GROK_MODELS_BASE_URL ourselves so plain Grok CLI sessions match.
  $applyArgs = @(
    'install', 'apply',
    '--preset', 'persistent-task',
    '--providers', 'manual',
    '--target', 'grok_build',
    '--scope', 'user',
    '--port', "$P",
    '--mode', 'cache',
    '--no-telemetry'
  )
  Write-Host ("  >> headroom " + ($applyArgs -join ' '))
  & $Hr @applyArgs 2>&1 | ForEach-Object { Write-Host ("     " + $_) }
  $code = $LASTEXITCODE
  if ($code -ne 0 -and $null -ne $code) {
    Warn ("headroom install apply exited $code - will still try env + start")
  } else {
    Ok 'headroom install apply completed'
  }
}

# ---- main ----
Step 'Headroom + Grok durable wrap'
$hr = Find-HeadroomExe
if (-not $hr) {
  Bad 'headroom.exe not found. Install Headroom first (AIO Components include headroom, or: pip/uv install headroom-ai[proxy,mcp]).'
  exit 2
}
Ok ("headroom = " + $hr)

$proxyUp = Test-HeadroomProxy -P $Port
$wrapUp = Test-GrokWrapRunning
$base = Get-GrokBaseUrl
$manifest = Get-HeadroomManifest
$hasGrokTarget = Test-GrokDeployTargets $manifest

if ($proxyUp) { Ok ("proxy healthy on port " + $Port) } else { Warn ("proxy NOT healthy on port " + $Port) }
if ($wrapUp) { Ok 'headroom wrap grok process is running (session wrap)' } else { Ok 'no live wrap process (OK if durable install apply is used)' }
if ($base -and $base -match '127\.0\.0\.1|localhost') {
  Ok ("GROK_* BASE_URL routes via Headroom: " + $base)
} elseif ($base) {
  Warn ("GROK_* BASE_URL set but unexpected: " + $base)
} else {
  Warn 'GROK_MODELS_BASE_URL / GROK_MODEL_GROK_BUILD_BASE_URL not set yet'
}

if ($hasGrokTarget) {
  Ok ('deploy manifest targets Grok: ' + ($manifest.targets -join ', '))
} elseif ($manifest) {
  Warn ('deploy manifest present but missing grok targets: ' + ($manifest.targets -join ', '))
} else {
  Warn 'No ~/.headroom/deploy/default manifest yet'
}

$doApply = -not $CheckOnly -and -not $SkipApply
if ($doApply -and -not $hasGrokTarget) {
  Invoke-HeadroomApply -Hr $hr -P $Port
  $manifest = Get-HeadroomManifest
  $hasGrokTarget = Test-GrokDeployTargets $manifest
  if ($hasGrokTarget) {
    Ok ('deploy now targets: ' + ($manifest.targets -join ', '))
  } else {
    Bad 'deploy still missing grok_build after install apply'
  }
} elseif ($doApply -and $hasGrokTarget) {
  Ok 'durable Grok deploy already present - skip install apply (idempotent)'
} elseif ($CheckOnly) {
  Ok 'CheckOnly: not applying deploy'
}

# Durable User env (install apply should set these; belt-and-suspenders for fresh machines
# where apply only set GROK_MODEL_GROK_BUILD_BASE_URL or mutations were skipped).
if (-not $CheckOnly) {
  Step 'Ensure durable User env routes Grok through Headroom proxy'
  $urlV1 = "http://127.0.0.1:$Port/v1"
  [void](Set-UserEnvIfMissing -Name 'GROK_MODELS_BASE_URL' -Value $urlV1)
  [void](Set-UserEnvIfMissing -Name 'GROK_MODEL_GROK_BUILD_BASE_URL' -Value $urlV1)
  # Process-level so the rest of this installer session sees the route immediately
  if (-not $env:GROK_MODELS_BASE_URL) { $env:GROK_MODELS_BASE_URL = $urlV1 }
  if (-not $env:GROK_MODEL_GROK_BUILD_BASE_URL) { $env:GROK_MODEL_GROK_BUILD_BASE_URL = $urlV1 }
}

# Start durable proxy if down (default on for installer; CheckOnly skips unless -StartProxyIfDown)
$wantStart = (-not $CheckOnly) -or $StartProxyIfDown
if ($wantStart) {
  $proxyUp = Test-HeadroomProxy -P $Port
  if (-not $proxyUp) {
    Step 'Starting durable Headroom deployment (does not kill other apps)'
    & $hr install start 2>&1 | ForEach-Object { Write-Host ("     " + $_) }
    Start-Sleep -Seconds 2
    if (-not (Test-HeadroomProxy -P $Port)) {
      # Fallback: ensure script from deploy profile if present
      $ensureCmd = Join-Path $env:USERPROFILE '.headroom\deploy\default\ensure-headroom.cmd'
      if (Test-Path -LiteralPath $ensureCmd) {
        Warn 'install start did not bring proxy up - trying deploy ensure-headroom.cmd'
        & cmd /c "`"$ensureCmd`"" 2>&1 | ForEach-Object { Write-Host ("     " + $_) }
        Start-Sleep -Seconds 2
      }
    }
    if (Test-HeadroomProxy -P $Port) { Ok 'proxy started' } else { Bad 'proxy still down after start attempts' }
  } else {
    Ok 'proxy already healthy - leave running wrap/proxy alone'
  }
}

if (-not $SkipMcp -and -not $CheckOnly) {
  Step 'Ensure Grok MCP headroom block (idempotent)'
  $packCommon = Join-Path $PSScriptRoot 'V5-Common.ps1'
  if (Test-Path -LiteralPath $packCommon) {
    . $packCommon
    Update-V5GrokMcpBlock -Name 'headroom' -Command $hr -ArgList @('mcp','serve') -Startup 60 -Tool 600 -SkipIfPresent
  } else {
    $cfg = Join-Path $env:USERPROFILE '.grok\config.toml'
    if (Test-Path -LiteralPath $cfg) {
      $txt = Get-Content -LiteralPath $cfg -Raw
      if ($txt -match '\[mcp_servers\.headroom\]') {
        Ok 'Grok MCP headroom already present'
      } else {
        Warn 'V5-Common.ps1 missing; run from V5 TOOLS folder or manually add [mcp_servers.headroom]'
      }
    }
  }
}

# Final status
$proxyUp = Test-HeadroomProxy -P $Port
$base = Get-GrokBaseUrl
$manifest = Get-HeadroomManifest
$hasGrokTarget = Test-GrokDeployTargets $manifest
$mcpOk = $false
$cfgPath = Join-Path $env:USERPROFILE '.grok\config.toml'
if (Test-Path -LiteralPath $cfgPath) {
  $cfgTxt = Get-Content -LiteralPath $cfgPath -Raw
  $mcpOk = ($cfgTxt -match '\[mcp_servers\.headroom\]')
}

Write-Host ''
Write-Host 'FRESH-INSTALL EXPECTATION (Grok + codebase):' -ForegroundColor Cyan
Write-Host '  1. Durable deploy targets grok_build (and preferably grok)'
Write-Host '  2. User env GROK_MODELS_BASE_URL -> http://127.0.0.1:PORT/v1'
Write-Host '  3. Headroom proxy healthy on that port'
Write-Host '  4. [mcp_servers.headroom] in ~/.grok/config.toml'
Write-Host '  5. codebase-memory-mcp at %LOCALAPPDATA%\Programs\codebase-memory-mcp\ (separate Fix script)'
Write-Host 'Optional session launch: headroom wrap grok   /   headroom wrap grok-build'
Write-Host ''

$pass = $true
if ($hasGrokTarget) { Ok 'PASS deploy targets Grok' } else { Bad 'FAIL deploy missing grok targets'; $pass = $false }
if ($base -match '127\.0\.0\.1|localhost') { Ok ("PASS routing env: $base") } else { Bad 'FAIL no Headroom GROK_* BASE_URL'; $pass = $false }
if ($proxyUp) { Ok 'PASS proxy healthy' } else { Bad 'FAIL proxy down'; $pass = $false }
if ($SkipMcp) { Ok 'SKIP MCP check' } elseif ($mcpOk) { Ok 'PASS Grok MCP headroom' } else { Warn 'WARN Grok MCP headroom missing (wire may run later in AIO)'; }

if ($pass) {
  Ok 'RESULT: fresh-install Headroom Grok wrap is APPLIED (durable) - same shape as a working machine'
  exit 0
}
Bad 'RESULT: Headroom Grok wrap incomplete - see messages above'
exit 1
