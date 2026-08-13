<#
.SYNOPSIS
  Add the `epic-scan` command to your PowerShell profile (Windows).

.DESCRIPTION
  Run once:
    gh api repos/pgetech/epic-compliance/contents/scripts/install.ps1 `
      -H "Accept: application/vnd.github.raw" | iex

  Idempotent: re-running replaces the existing block instead of duplicating it.
#>
$ErrorActionPreference = "Stop"

$ProfilePath = $PROFILE.CurrentUserAllHosts

# Ensure the profile file (and its directory) exist.
$dir = Split-Path $ProfilePath
if (-not (Test-Path $dir))         { New-Item -ItemType Directory -Force -Path $dir         | Out-Null }
if (-not (Test-Path $ProfilePath)) { New-Item -ItemType File      -Force -Path $ProfilePath | Out-Null }

$start = "# >>> epic-scan >>>"
$end   = "# <<< epic-scan <<<"
$block = @'
# >>> epic-scan >>>
# EPIC compliance gate - local shift-left runner (self-updating).
function epic-scan {
  $t = "$env:TEMP\epic-scan.ps1"
  gh api repos/pgetech/epic-compliance/contents/scripts/epic-scan.ps1 -H "Accept: application/vnd.github.raw" | Out-File -Encoding utf8 $t
  & $t @args
}
# <<< epic-scan <<<
'@

# Remove any prior block so re-running just refreshes it.
$content = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue
if ($null -ne $content -and $content -match [regex]::Escape($start)) {
  $pattern = "(?s)" + [regex]::Escape($start) + ".*?" + [regex]::Escape($end)
  $content = ([regex]::Replace($content, $pattern, "")).TrimEnd()
  Set-Content -Path $ProfilePath -Value $content -Encoding utf8
}

Add-Content -Path $ProfilePath -Value "`n$block" -Encoding utf8

Write-Host "Installed 'epic-scan' into $ProfilePath"
Write-Host "Start a new terminal, then:  epic-scan C:\path\to\your\app"
