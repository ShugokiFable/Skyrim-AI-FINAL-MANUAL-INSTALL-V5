# Fix-Grok-Codebase-Memory-Direct.ps1
# Wires codebase-memory-mcp into %USERPROFILE%\.grok\config.toml
# Portable: discovers exe or accepts -ExePath

param(
  [string]$ExePath = ""
)

$ErrorActionPreference = "Stop"

function Find-CodebaseMemoryExe {
  param([string]$Hint)
  if ($Hint -and (Test-Path -LiteralPath $Hint -PathType Leaf)) { return (Resolve-Path -LiteralPath $Hint).Path }
  if ($env:CODEBASE_MEMORY_MCP -and (Test-Path -LiteralPath $env:CODEBASE_MEMORY_MCP)) {
    return (Resolve-Path -LiteralPath $env:CODEBASE_MEMORY_MCP).Path
  }
  $default = Join-Path $env:LOCALAPPDATA "Programs\codebase-memory-mcp\codebase-memory-mcp.exe"
  if (Test-Path -LiteralPath $default -PathType Leaf) { return (Resolve-Path -LiteralPath $default).Path }
  return $null
}

$exe = Find-CodebaseMemoryExe -Hint $ExePath
if (-not $exe) {
  Write-Host "codebase-memory-mcp.exe not found." -ForegroundColor Red
  Write-Host "Install: https://github.com/DeusData/codebase-memory-mcp" -ForegroundColor Yellow
  Write-Host "Then re-run: .\Fix-Grok-Codebase-Memory-Direct.ps1 -ExePath 'D:\path\codebase-memory-mcp.exe'" -ForegroundColor Yellow
  exit 1
}

Unblock-File -LiteralPath $exe -ErrorAction SilentlyContinue

Write-Host "Testing codebase-memory-mcp..." -ForegroundColor Cyan
& $exe --version
if ($LASTEXITCODE -ne 0) { throw "codebase-memory-mcp.exe failed to start." }

$grokDir = Join-Path $env:USERPROFILE ".grok"
$configPath = Join-Path $grokDir "config.toml"
New-Item -ItemType Directory -Path $grokDir -Force | Out-Null

if (Test-Path -LiteralPath $configPath) {
  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $backupPath = "$configPath.before-codebase-memory-fix-$timestamp.bak"
  Copy-Item -LiteralPath $configPath -Destination $backupPath -Force
  Write-Host "Backup created: $backupPath" -ForegroundColor DarkGray
  $content = Get-Content -LiteralPath $configPath -Raw
} else {
  $content = ""
}

$sectionPattern = '(?ms)^[ \t]*\[mcp_servers\.(?:codebase-memory-mcp|"codebase-memory-mcp"|''codebase-memory-mcp'')\][ \t]*\r?\n.*?(?=^[ \t]*\[|\z)'
$content = [regex]::Replace($content, $sectionPattern, "")
$content = [regex]::Replace($content, '(\r?\n){3,}', "`r`n`r`n").Trim()

$tomlExe = $exe.Replace('\', '/')
$block = @"
[mcp_servers.codebase-memory-mcp]
command = "$tomlExe"
args = []
enabled = true
startup_timeout_sec = 90
tool_timeout_sec = 6000
"@

if ($content.Length -gt 0) {
  $newContent = $content.TrimEnd() + "`r`n`r`n" + $block.Trim() + "`r`n"
} else {
  $newContent = $block.Trim() + "`r`n"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, $newContent, $utf8NoBom)

Write-Host ""
Write-Host "Grok MCP configuration repaired." -ForegroundColor Green
Write-Host "Configured executable:" -ForegroundColor Cyan
Write-Host "  $exe"
Write-Host ""
Write-Host "Close every Grok window, open a fresh session, then use /mcp." -ForegroundColor Yellow
