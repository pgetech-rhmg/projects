<powershell>
$ErrorActionPreference='Stop'
function L($m){ Write-Output "$(Get-Date -Format s) $m" }
L 'Start bootstrap'

# Skip if already running
try { if((Get-Service CodeDeployAgent -ErrorAction Stop).Status -eq 'Running'){ L 'Already running - exit'; return } } catch { L 'Not installed yet' }

# Fast install
New-Item -ItemType Directory -Force -Path C:\temp | Out-Null
$url='https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/codedeploy-agent.msi'
$msi='C:\temp\codedeploy-agent.msi'

for($i=1; $i -le 3; $i++){ try{ L "Download $i"; Invoke-WebRequest -Uri $url -OutFile $msi -TimeoutSec 90; break } catch { if($i -eq 3){ throw }; Start-Sleep 5 } }

L 'Installing MSI'
$p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /norestart" -Wait -PassThru
if($p.ExitCode -ne 0){ L "Install failed: $($p.ExitCode)"; exit 1 }
Remove-Item $msi -Force -ErrorAction SilentlyContinue

# Robust service start (up to 60s with retries)
Set-Service CodeDeployAgent -StartupType Automatic -ErrorAction SilentlyContinue
$sw=[Diagnostics.Stopwatch]::StartNew()
while($sw.Elapsed.TotalSeconds -lt 60){
  try {
    $svc = Get-Service CodeDeployAgent -ErrorAction Stop
    if($svc.Status -ne 'Running'){ Start-Service CodeDeployAgent -ErrorAction SilentlyContinue; Start-Sleep 3 }
    $svc = Get-Service CodeDeployAgent
    L "Status: $($svc.Status) @ $([int]$sw.Elapsed.TotalSeconds)s"
    if($svc.Status -eq 'Running'){ L 'Service running - success'; break }
  }
  catch { L "Error: $($_.Exception.Message)" }
  Start-Sleep 7
}

# Final check
$final = Get-Service CodeDeployAgent
if($final.Status -ne 'Running'){ L 'FAILED to start after 60s'; exit 2 }

# Memory tweak + cleanup
try { Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles -Value 'C:\pagefile.sys 8192 16384' } catch { L 'Paging adjust failed (ok)' }
Remove-Item C:\temp -Recurse -Force -ErrorAction SilentlyContinue
L 'Bootstrap complete - CodeDeploy ready'
</powershell>
