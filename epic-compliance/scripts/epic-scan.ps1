<#
.SYNOPSIS
  Run the EPIC compliance gate locally on Windows.

.EXAMPLE
  .\epic-scan.ps1 C:\code\my-app

.DESCRIPTION
  Downloads the version-pinned epic-compliance binary from GitHub Releases (the
  same tool the EPIC pipeline runs), scans the given source tree, prints a
  summary, and writes a readable report + a SARIF file next to the app.
  Exit code is the gate:  0 = compliant   1 = a HARD control failed   2 = error

  Prereqs: the GitHub CLI (gh), logged in to the pgetech org
           (run `gh auth login` once). No AWS access needed.
#>
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$AppPath
)

$ErrorActionPreference = "Stop"

$Repo    = "pgetech/epic-compliance"
$Release = "local"   # rolling release of always-latest, unversioned binaries

# --- 1. Validate the one argument --------------------------------------------
if (-not (Test-Path -Path $AppPath -PathType Container)) {
  Write-Error "Usage: .\epic-scan.ps1 <path-to-app>   (a directory to scan)"
  exit 2
}
$AppPath = (Resolve-Path $AppPath).Path

# --- 2. Binary for this machine (Windows x64) --------------------------------
$Asset = "epic-compliance-windows-amd64.exe"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "GitHub CLI (gh) not found. Install it, then run: gh auth login"
  exit 2
}

# --- 3. Always fetch the latest binary (rolling release, never pinned) -------
$Bin = Join-Path $env:TEMP $Asset
Write-Host ">> Fetching latest epic-compliance from GitHub..."
gh release download $Release --repo $Repo --pattern $Asset --output $Bin --clobber
if ($LASTEXITCODE -ne 0) {
  Write-Error "Download failed. Make sure you're logged in: gh auth login"
  exit 2
}

# --- 4. Detect appType from the app's EPIC contract (optional) ---------------
$AppType  = ""
$Contract = Join-Path $AppPath ".pipeline\epic.json"
if (Test-Path $Contract) {
  try { $AppType = (Get-Content $Contract -Raw | ConvertFrom-Json).app.appType } catch { $AppType = "" }
}

# --- 5. Scan ------------------------------------------------------------------
$suffix = if ($AppType) { "  (appType=$AppType)" } else { "" }
Write-Host ">> Scanning $AppPath$suffix"
Write-Host ">> Reports: $AppPath\compliance.md  and  $AppPath\compliance.sarif"
Write-Host ""

$scanArgs = @($AppPath)
if ($AppType) { $scanArgs += @("--app-type", $AppType) }
$scanArgs += @(
  "--md",    (Join-Path $AppPath "compliance.md"),
  "--sarif", (Join-Path $AppPath "compliance.sarif"),
  "--fail-on", "hard-fail"
)

& $Bin @scanArgs
$Code = $LASTEXITCODE

Write-Host ""
switch ($Code) {
  0 { Write-Host ">> PASS - no gating findings. (details in compliance.md)" }
  1 { Write-Host ">> FAIL - a HARD control failed. This would block the EPIC pipeline. See compliance.md" }
  default { Write-Host ">> ERROR - scan did not complete (exit $Code)." }
}
exit $Code
