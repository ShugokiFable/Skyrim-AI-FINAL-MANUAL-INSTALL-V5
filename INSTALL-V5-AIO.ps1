<#
.SYNOPSIS
  Skyrim AI V5 - All-In-One installer for skills, plugins, MCP tools, and houseCARL (MO2/Vortex).

.DESCRIPTION
  New users: run this once from the pack root.
  - Installs provider skills (Claude/Codex/Grok/Kimi/Hermes)
  - Installs bundled offline tools OR fetches GitHub latest
  - Wires Grok MCP (housecarl, codebase-memory, headroom)
  - Runs houseCARL MO2/Vortex setup
  - Writes discovery state

.PARAMETER Providers
  Which AI apps to install skills for. Default: all five.

.PARAMETER Mode
  BundledFirst | OnlineLatest | BundledOnly

.PARAMETER Components
  Tool components to install. Default: core set (not codeburn desktop).

.PARAMETER WorkspaceRoot
  Optional workspace to receive AGENTS.md / CLAUDE.md / _PROJECT-TEMPLATE

.PARAMETER SkipRuntimes
  Do not try winget for .NET/Python/Node

.PARAMETER SkipHouseCarlSetup
  Do not run Setup-HouseCarl.ps1 at the end

.PARAMETER SkipMcpWire
  Do not edit Grok config.toml

.EXAMPLE
  .\INSTALL-V5-AIO.ps1
  .\INSTALL-V5-AIO.ps1 -Providers Grok,Claude -Mode OnlineLatest
  .\INSTALL-V5-AIO.ps1 -WorkspaceRoot "D:\Modding\AI-Workspace"
#>
[CmdletBinding()]
param(
  [ValidateSet('Claude','Codex','Grok','Kimi','Hermes')]
  [string[]]$Providers = @('Claude','Codex','Grok','Kimi','Hermes'),
  [ValidateSet('BundledFirst','OnlineLatest','BundledOnly')]
  [string]$Mode = 'BundledFirst',
  [string[]]$Components = @('housecarl','spooky','codebase-memory','headroom','superpowers','ponytail','codeburn'),
  [string]$WorkspaceRoot = '',
  [switch]$SkipRuntimes,
  [switch]$SkipHouseCarlSetup,
  [switch]$SkipMcpWire,
  [switch]$SkillsOnly,
  [switch]$ToolsOnly
)

$ErrorActionPreference = 'Stop'
$PackRoot = $PSScriptRoot
if (-not (Test-Path (Join-Path $PackRoot 'BUNDLED-TOOLS\CATALOG.json'))) {
  throw "Run INSTALL-V5-AIO.ps1 from the V5 pack root (folder containing BUNDLED-TOOLS)."
}
. (Join-Path $PackRoot 'TOOLS\V5-Common.ps1')
$script:V5PackRoot = $PackRoot
$catalog = Get-V5Catalog
$offline = Join-Path $PackRoot 'BUNDLED-TOOLS\offline'
$cache = Join-Path $PackRoot 'BUNDLED-TOOLS\cache'
$plugins = Join-Path $PackRoot 'BUNDLED-TOOLS\plugins'
$log = [System.Collections.Generic.List[string]]::new()
function L($m){ [void]$log.Add("$(Get-Date -Format o) $m"); Write-Host $m }

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Magenta
Write-Host " Skyrim AI V5.0.0 - ALL-IN-ONE INSTALLER" -ForegroundColor Magenta
Write-Host " Mode=$Mode  Providers=$($Providers -join ',')" -ForegroundColor Magenta
Write-Host "=====================================================" -ForegroundColor Magenta
Write-Host ""

# ---------- Runtimes ----------
if (-not $SkipRuntimes -and -not $SkillsOnly) {
  Write-V5Step "Runtime checks"
  $needNet9 = -not (Test-V5DotNetRuntime 'Microsoft\.NETCore\.App 9\.')
  $needAsp9 = -not (Test-V5DotNetRuntime 'Microsoft\.AspNetCore\.App 9\.')
  if ($needNet9) { Install-V5Winget @('Microsoft.DotNet.Runtime.9') | Out-Null } else { Write-V5Ok '.NET 9 runtime' }
  if ($needAsp9) { Install-V5Winget @('Microsoft.DotNet.AspNetCore.9') | Out-Null } else { Write-V5Ok 'ASP.NET Core 9' }
  if (-not (Get-Command python -EA SilentlyContinue) -and -not (Get-Command py -EA SilentlyContinue)) {
    Write-V5Warn 'Python not found (needed for Headroom) - attempting winget'
    Install-V5Winget @('Python.Python.3.12') | Out-Null
  } else { Write-V5Ok 'Python present' }
  if (-not (Get-Command node -EA SilentlyContinue)) {
    Write-V5Warn 'Node not found (optional CodeBurn) - attempting winget LTS'
    Install-V5Winget @('OpenJS.NodeJS.LTS') | Out-Null
  } else { Write-V5Ok "Node $(node -v)" }
  if (-not (Get-Command dotnet -EA SilentlyContinue)) {
    Write-V5Warn 'dotnet SDK/runtime host missing - Spooky CLI may need SDK 8'
  }
}

function Get-ComponentAssetPath {
  param($Comp)
  $name = $Comp.offline_asset
  if ($Mode -eq 'OnlineLatest') {
    # prefer cache newest matching
    if ($Comp.github) {
      try {
        $rel = Invoke-V5GitHubLatest -Owner $Comp.github.owner -Repo $Comp.github.repo
        $asset = $null
        if ($Comp.asset_match) { $asset = Get-V5ReleaseAsset -Release $rel -Patterns @($Comp.asset_match) }
        if ($asset) {
          $dest = Join-Path $cache $asset.name
          if (-not (Test-Path $dest) -or (Get-Item $dest).Length -lt 1000) {
            Save-V5Url -Url $asset.browser_download_url -OutFile $dest
          }
          return $dest
        }
        if ($Comp.kind -eq 'skills-plugin') {
          $dest = Join-Path $cache "$($Comp.id)-$($rel.tag_name).zip"
          if (-not (Test-Path $dest)) {
            $zipUrl = "https://github.com/$($Comp.github.owner)/$($Comp.github.repo)/archive/refs/tags/$($rel.tag_name).zip"
            try { Save-V5Url -Url $zipUrl -OutFile $dest } catch { Save-V5Url -Url $rel.zipball_url -OutFile $dest }
          }
          return $dest
        }
      } catch { Write-V5Warn "OnlineLatest failed for $($Comp.id): $($_.Exception.Message)" }
    }
  }
  if ($name) {
    $p = Join-Path $offline $name
    if (Test-Path $p) { return $p }
    # any cache match
    if ($Comp.asset_match) {
      foreach ($pat in $Comp.asset_match) {
        $hit = Get-ChildItem $cache,$offline -Filter $pat -File -EA SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($hit) { return $hit.FullName }
      }
    }
  }
  if ($Mode -eq 'BundledOnly') { return $null }
  # fallback online
  if ($Comp.github) {
    try {
      $rel = Invoke-V5GitHubLatest -Owner $Comp.github.owner -Repo $Comp.github.repo
      $asset = $null
      if ($Comp.asset_match) { $asset = Get-V5ReleaseAsset -Release $rel -Patterns @($Comp.asset_match) }
      if ($asset) {
        $dest = Join-Path $cache $asset.name
        Save-V5Url -Url $asset.browser_download_url -OutFile $dest
        return $dest
      }
    } catch {}
  }
  return $null
}

# ---------- Skills ----------
if (-not $ToolsOnly) {
  Write-V5Step "Installing provider skills"
  $tailored = Join-Path $PackRoot '1-RECOMMENDED-SEPARATE-TAILORED'
  foreach ($prov in $Providers) {
    $srcSkills = Join-Path $tailored "$prov\COPY-TO-SKILLS-DIRECTORY\skills"
    if (-not (Test-Path $srcSkills)) { Write-V5Bad "Missing $srcSkills"; continue }
    $providerHome = Get-V5ProviderHome -Provider $prov -Catalog $catalog
    $destSkills = Join-Path $providerHome 'skills'
    Write-Host "  $prov -> $destSkills"
    Copy-V5Robo -From $srcSkills -To $destSkills
    # provider home instructions
    $pmeta = $catalog.providers.$prov
    if ($pmeta.instructions) {
      $srcInst = Join-Path $tailored "$prov\COPY-TO-PROVIDER-HOME\$($pmeta.instruction_src)"
      if (-not (Test-Path $srcInst)) {
        $srcInst = Join-Path $tailored "$prov\COPY-TO-WORKSPACE\$($pmeta.instruction_src)"
      }
      # Claude uses CLAUDE.md
      if ($prov -eq 'Claude') {
        $srcInst = Join-Path $tailored 'Claude\COPY-TO-PROVIDER-HOME\CLAUDE.md'
        if (-not (Test-Path $srcInst)) { $srcInst = Join-Path $PackRoot 'COPY-TO-YOUR-WORKSPACE\CLAUDE.md' }
      }
      if (Test-Path $srcInst) {
        Copy-Item $srcInst (Join-Path $providerHome $pmeta.instructions) -Force
        Write-V5Ok ("{0} instructions -> {1}\{2}" -f $prov, $providerHome, $pmeta.instructions)
      }
    }
    Write-V5Ok "$prov skills installed"
  }
}

# ---------- Workspace ----------
if ($WorkspaceRoot) {
  Write-V5Step "Workspace files -> $WorkspaceRoot"
  New-Item -ItemType Directory -Force -Path $WorkspaceRoot | Out-Null
  $ws = Join-Path $PackRoot 'COPY-TO-YOUR-WORKSPACE'
  Copy-Item (Join-Path $ws 'AGENTS.md') (Join-Path $WorkspaceRoot 'AGENTS.md') -Force -EA SilentlyContinue
  Copy-Item (Join-Path $ws 'CLAUDE.md') (Join-Path $WorkspaceRoot 'CLAUDE.md') -Force -EA SilentlyContinue
  $tpl = Join-Path $ws '_PROJECT-TEMPLATE'
  if (Test-Path $tpl) { Copy-V5Robo -From $tpl -To (Join-Path $WorkspaceRoot '_PROJECT-TEMPLATE') }
  Write-V5Ok "Workspace template copied"
}

# ---------- Tools ----------
$installed = [ordered]@{}
if (-not $SkillsOnly) {
  foreach ($id in $Components) {
    $comp = $catalog.components | Where-Object { $_.id -eq $id } | Select-Object -First 1
    if (-not $comp) { Write-V5Warn "skip unknown $id"; continue }
    Write-V5Step "Component: $($comp.name) [$id]"

    switch ($comp.install) {
      'manual-user-product' {
        Write-V5Warn $comp.note
        $installed[$id] = @{ status='manual'; note=$comp.note }
      }
      'npx-or-npm' {
        if (Get-Command npm -EA SilentlyContinue) {
          try {
            & npm install -g $comp.npm_spec 2>&1 | Out-Host
            $installed[$id] = @{ status='npm-global'; spec=$comp.npm_spec }
            Write-V5Ok "npm -g $($comp.npm_spec)"
          } catch {
            Write-V5Warn "npm global failed - users can run: npx $($comp.npm_spec)"
            $installed[$id] = @{ status='npx-fallback' }
          }
        } else {
          Write-V5Warn "Node/npm missing - CodeBurn via npx when Node is installed"
          $installed[$id] = @{ status='skipped-no-node' }
        }
      }
      'pip-or-wheel' {
        $py = $null
        foreach ($c in @('python','py')) {
          if (Get-Command $c -EA SilentlyContinue) { $py = $c; break }
        }
        $asset = Get-ComponentAssetPath -Comp $comp
        $ok = $false
        if ($asset -and $asset.EndsWith('.whl') -and $py) {
          Write-Host "  pip install $asset"
          if ($py -eq 'py') { & py -3 -m pip install --user $asset 2>&1 | Out-Host }
          else { & python -m pip install --user $asset 2>&1 | Out-Host }
          $ok = $true
        }
        if (-not $ok -and $py) {
          $spec = $comp.pip_spec
          if ($py -eq 'py') { & py -3 -m pip install --user $spec 2>&1 | Out-Host }
          else { & python -m pip install --user $spec 2>&1 | Out-Host }
          $ok = $true
        }
        if ($ok) {
          $hr = $null
          try { $hr = (Get-Command headroom -EA SilentlyContinue).Source } catch {}
          if ($hr) { Set-V5UserEnv 'HEADROOM_CMD' $hr }
          $installed[$id] = @{ status='pip'; headroom=$hr }
          Write-V5Ok 'Headroom installed'
        } else {
          Write-V5Bad 'Headroom install failed (need Python)'
          $installed[$id] = @{ status='failed' }
        }
      }
      'skills-copy' {
        # already in provider skills from pack; also ensure plugin tree for Claude
        $plugSrc = Join-Path $plugins $id
        if (Test-Path $plugSrc) {
          foreach ($prov in $Providers) {
            if ($prov -ne 'Claude') { continue }
            $providerHome = Get-V5ProviderHome -Provider Claude -Catalog $catalog
            $dest = Join-Path $providerHome "plugins\v5-bundled\$id"
            Copy-V5Robo -From $plugSrc -To $dest
            Write-V5Ok "Claude plugin tree $id -> $dest"
          }
        }
        $installed[$id] = @{ status='skills+plugin' }
        Write-V5Ok "$id skills present via provider skill install"
      }
      'zip-extract' {
        $asset = Get-ComponentAssetPath -Comp $comp
        if (-not $asset) {
          Write-V5Bad "No asset for $id - run TOOLS\Update-From-GitHub.ps1 -$id or check network"
          $installed[$id] = @{ status='missing-asset' }
          continue
        }
        $target = Expand-V5EnvPath $comp.target_dir
        $stage = Join-Path $env:TEMP "v5-extract-$id-$(Get-Random)"
        New-Item -ItemType Directory -Force -Path $stage | Out-Null
        try {
          Expand-V5Zip -Zip $asset -Dest $stage
          $rootExtract = Resolve-V5SingleRoot $stage
          # houseCARL zip layout: may contain housecarl\server or server
          if ($id -eq 'housecarl') {
            $mcp = Find-V5FileUnder $rootExtract 'housecarl-mcp.exe' 8
            if (-not $mcp) { throw "housecarl-mcp.exe not in zip" }
            $serverDir = Split-Path $mcp -Parent
            $productRoot = Split-Path $serverDir -Parent
            # Install to LOCALAPPDATA\houseCARL
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            Copy-V5Robo -From $productRoot -To $target
            # If setup exe present at outer folder
            $setup = Find-V5FileUnder $rootExtract 'houseCARL-Setup.exe' 4
            if ($setup) {
              Copy-Item $setup (Join-Path $target 'houseCARL-Setup.exe') -Force
            }
            $mcpFinal = Join-Path $target 'server\housecarl-mcp.exe'
            if (-not (Test-Path $mcpFinal)) { $mcpFinal = Find-V5FileUnder $target 'housecarl-mcp.exe' 5 }
            Set-V5UserEnv 'HOUSECARL_MCP' $mcpFinal
            Set-V5UserEnv 'HOUSECARL_ROOT' $target
            $installed[$id] = @{ status='installed'; mcp=$mcpFinal; root=$target }
            Write-V5Ok "houseCARL -> $target"
          }
          elseif ($id -eq 'codebase-memory') {
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            # zip may be flat exe
            Copy-V5Robo -From $rootExtract -To $target
            $exe = Join-Path $target 'codebase-memory-mcp.exe'
            if (-not (Test-Path $exe)) { $exe = Find-V5FileUnder $target 'codebase-memory-mcp.exe' 4 }
            if (-not $exe) { throw "codebase-memory-mcp.exe missing after extract" }
            Set-V5UserEnv 'CODEBASE_MEMORY_MCP' $exe
            $installed[$id] = @{ status='installed'; exe=$exe }
            Write-V5Ok "codebase-memory -> $exe"
          }
          elseif ($id -eq 'spooky') {
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            Copy-V5Robo -From $rootExtract -To $target
            # find sln
            $sln = Find-V5FileUnder $target 'SpookysAutomod.sln' 5
            $toolkitRoot = if ($sln) { Split-Path $sln -Parent } else { $target }
            # nested spookys-automod-toolkit folder
            $inner = Join-Path $toolkitRoot 'spookys-automod-toolkit'
            if (Test-Path (Join-Path $inner 'SpookysAutomod.sln')) { $toolkitRoot = $inner }
            Set-V5UserEnv 'SPOOKY_AUTOMOD_ROOT' $toolkitRoot
            $installed[$id] = @{ status='installed'; root=$toolkitRoot }
            Write-V5Ok "Spooky -> $toolkitRoot"
            Write-V5Warn "Optional: run SpookysAutomodSetup.exe inside the toolkit folder for headers/compiler"
          }
          else {
            Copy-V5Robo -From $rootExtract -To $target
            $installed[$id] = @{ status='installed'; root=$target }
          }
        } finally {
          Remove-Item -LiteralPath $stage -Recurse -Force -EA SilentlyContinue
        }
      }
      default { Write-V5Warn "No installer for $($comp.install)" }
    }
  }
}

# ---------- MCP wire (Grok) ----------
if (-not $SkipMcpWire -and -not $SkillsOnly -and ($Providers -contains 'Grok')) {
  Write-V5Step "Wiring Grok MCP servers"
  $hc = [Environment]::GetEnvironmentVariable('HOUSECARL_MCP','User')
  if (-not $hc) { $hc = $env:HOUSECARL_MCP }
  if ($hc -and (Test-Path $hc)) {
    Update-V5GrokMcpBlock -Name 'housecarl' -Command $hc -Startup 120 -Tool 6000 -EnvMap @{ HouseCarl__Mo2InstanceDir = '%SKYRIM_MO2_INSTANCE%' }
  }
  $cm = [Environment]::GetEnvironmentVariable('CODEBASE_MEMORY_MCP','User')
  if (-not $cm) { $cm = $env:CODEBASE_MEMORY_MCP }
  if ($cm -and (Test-Path $cm)) {
    Update-V5GrokMcpBlock -Name 'codebase-memory-mcp' -Command $cm -Startup 90 -Tool 6000
  }
  $hr = $null
  try { $hr = (Get-Command headroom -EA SilentlyContinue).Source } catch {}
  if (-not $hr) { $hr = [Environment]::GetEnvironmentVariable('HEADROOM_CMD','User') }
  if ($hr -and (Test-Path $hr)) {
    Update-V5GrokMcpBlock -Name 'headroom' -Command $hr -ArgList @('mcp','serve') -Startup 60 -Tool 600
  } elseif ($hr) {
    # might be bare command name
    Update-V5GrokMcpBlock -Name 'headroom' -Command 'headroom' -ArgList @('mcp','serve') -Startup 60 -Tool 600
  }
  # Forge if INSTALLATION.json exists in grok skills
  $forgeInst = Join-Path (Get-V5ProviderHome Grok $catalog) 'skills\skyrim-forge\INSTALLATION.json'
  if (Test-Path $forgeInst) {
    try {
      $j = Get-Content $forgeInst -Raw | ConvertFrom-Json
      if ($j.mcp -and $j.mcp.Count -ge 1) {
        $cmd = $j.mcp[0]
        $args = @()
        if ($j.mcp.Count -gt 1) { $args = @($j.mcp[1..($j.mcp.Count-1)]) }
        Update-V5GrokMcpBlock -Name 'skyrim-forge' -Command $cmd -ArgList $args -Startup 120 -Tool 6000
      }
    } catch { Write-V5Warn "Forge MCP wire skipped: $_" }
  } else {
    Write-V5Warn "Skyrim Forge not configured (optional). Set SKYRIM_FORGE_ROOT or skill INSTALLATION.json"
  }
}

# ---------- houseCARL MO2/Vortex ----------
if (-not $SkipHouseCarlSetup -and -not $SkillsOnly) {
  $setup = Join-Path $PackRoot 'TOOLS\Setup-HouseCarl.ps1'
  if (Test-Path $setup) {
    Write-V5Step "houseCARL MO2/Vortex setup"
    try {
      & powershell -NoProfile -ExecutionPolicy Bypass -File $setup
      $installed['housecarl-setup'] = @{ status='ran' }
    } catch {
      Write-V5Warn "Setup-HouseCarl: $($_.Exception.Message)"
      $installed['housecarl-setup'] = @{ status='error'; error=$_.Exception.Message }
    }
  }
}

# ---------- Discover + state ----------
Write-V5Step "Post-install discovery"
$disc = Join-Path $PackRoot 'TOOLS\discover_tools.ps1'
if (Test-Path $disc) {
  & powershell -NoProfile -File $disc | Tee-Object -Variable discOut | Out-Host
}

$stateDir = Join-Path $env:LOCALAPPDATA 'Skyrim-AI-V5'
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
$state = @{
  version = '5.0.0'
  installed_utc = [DateTime]::UtcNow.ToString('o')
  mode = $Mode
  providers = $Providers
  components = $installed
  pack_root = $PackRoot
}
$state | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $stateDir 'install-state.json') -Encoding UTF8
$log | Set-Content (Join-Path $stateDir 'install-log.txt') -Encoding UTF8

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host " INSTALL COMPLETE" -ForegroundColor Green
Write-Host " State: $stateDir\install-state.json" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host 'NEXT STEPS:' -ForegroundColor Yellow
Write-Host '  1. FULLY restart every AI app you use (Grok / Claude / Codex / ...).'
Write-Host '  2. Grok: run /mcp and confirm housecarl, codebase-memory-mcp, headroom.'
Write-Host '  3. Claude houseCARL plugin: set MO2 instance to SKYRIM_MO2_INSTANCE path.'
Write-Host '  4. Vortex users after LO changes: TOOLS\Setup-HouseCarl.ps1 -RefreshOnly'
Write-Host '  5. Update tools later: TOOLS\Update-From-GitHub.ps1'
Write-Host '  6. Optional Forge: set SKYRIM_FORGE_ROOT or skill INSTALLATION.json'
Write-Host ''
Write-Host 'AI usage: skills load automatically. Start with skyrim-memory + skyrim-tool-router.'
Write-Host 'Missing tools: run TOOLS\Ensure-Tools.ps1 or INSTALL-V5-AIO.ps1 - do not invent paths.'
Write-Host ''