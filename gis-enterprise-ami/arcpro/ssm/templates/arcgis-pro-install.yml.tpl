schemaVersion: "2.2"
description: |
  Install ArcGIS Pro with all dependencies and patches.
  This document Installs ArcGIS Pro, dependencies and patches on Windows instances.
  Target instances using instance IDs or tags when running the command.
parameters:
  ArcProVersion:
    type: String
    description: The version of ArcGIS Pro to upgrade or install
    allowedValues:
      - "3.5"
      - "3.6"
    default: "3.5"
  AuthorizationType:
    type: String
    description: ArcGIS Pro authorization method
    allowedValues:
      - NAMED_USER
      - SINGLE_USE
    default: NAMED_USER
  ArcProLicenseFile:
    type: String
    description: (Required for SINGLE_USE AuthorizationType) S3 Key of ArcGIS Pro license file
    default: "${ArcProLicenseFile}"
  PortalLicenseURL:
    type: String
    description: (Required for NAMED_USER) Portal for ArcGIS or ArcGIS Online URL
    default: "${PortalLicenseURL}"
  PortalList:
    type: String
    description: Semicolon-separated list of Portal URLs for connection
    default: "${PortalList}"
  ArcProInstallDrive:
    type: String
    description: Drive letter for ArcGIS Pro installation
    default: "G:"
  GeodataSentryInstallerS3Key:
    type: String
    description: (Optional) S3 Key for Geodata Sentry installer.if not specified, Geodata Sentry installation will be skipped.
    default: "geodata_sentry"
  UDCtoolInstallerS3Key:
    type: String
    description: (Optional) S3 Key for UDC tools installer.if not specified, UDC tools installation will be skipped.
    default: "udc_tool"
  NVIDIABucket:
    type: String
    description: (Optional) NVIDIA Driver bucket name, required for gpu instance.
    default: 'ec2-windows-nvidia-drivers'
  NVIDIABucketKeyPrefix:
    type: String
    description: (Required) NVIDIA Driver Key Prefix.
    default: 'latest'
  AWSRegion:
    type: String
    description: AWS region for S3 operations.
    default: 'us-west-2'
    allowedValues:
      - 'us-west-2'
      - 'us-east-1'
      - 'us-east-2'

mainSteps:
  - name: CreateInstallConfig
    action: 'aws:runPowerShellScript'
    description: Creates installation configuration based on ArcGIS Pro version
    inputs:
      timeoutSeconds: '60'
      runCommand:
        - |
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'

          # Create Install directory and initialize log file
          $logDir = "{{ ArcProInstallDrive }}\installer\$version\logs"
          if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
          }
          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          Start-Transcript -Path $logFile -Append
          Write-Output "Log file created at: $logFile"

          # Set timezone to Pacific Standard Time
          try {
            Set-TimeZone -Id "Pacific Standard Time" -ErrorAction Stop
            Write-Output "Timezone set to Pacific Standard Time"
          } catch {
            Write-Warning "Failed to set timezone: $_"
          }

          Write-Output "Setting defaults for ArcGIS Pro version: $version"
          # Define version-specific configurations
          # This mapping automatically determines installer paths and patches based on version
          $versionConfig = @{
            '3.5' = @{
              InstallS3Bucket = 'elevate-installer'
              ArcProInstallerS3Key = 'esri/arcgis_pro/arcgis_pro_3_5/ArcGISPro_35_195271.exe'
              DotnetRuntimeInstallerS3Key = 'dotnet_runtime/8_0'
              DotnetRuntimeInstaller = 'windowsdesktop-runtime-8.0.22-win-x64.exe,MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
              ArcProPatchesS3Key = 'esri/arcgis_pro/arcgis_pro_3_5/patches'
              ArcProPatches = 'ArcGIS_Pro_355_195505.msp'
              InstallLocation = '{{ ArcProInstallDrive }}\ArcGIS\Pro'
            }
            '3.6' = @{
              InstallS3Bucket = 'elevate-installer'
              ArcProInstallerS3Key = 'esri/arcgis_pro/arcgis_pro_3_6/ArcGISPro_36_197382.exe'
              DotnetRuntimeInstallerS3Key = 'dotnet_runtime/8_0'
              DotnetRuntimeInstaller = 'windowsdesktop-runtime-8.0.22-win-x64.exe,MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
              ArcProPatchesS3Key = 'esri/arcgis_pro/arcgis_pro_3_6/patches'
              ArcProPatches = ''
              InstallLocation = '{{ ArcProInstallDrive }}\ArcGIS\Pro'
            }
          }

          if ($versionConfig.ContainsKey($version)) {
            # Create installation configuration file
            $configPath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
            $config = @{
              Version = $version
              InstallS3Bucket = $versionConfig[$version].InstallS3Bucket
              ArcProInstallerS3Key = $versionConfig[$version].ArcProInstallerS3Key
              ArcProPatchesS3Key = $versionConfig[$version].ArcProPatchesS3Key
              ArcProPatches = $versionConfig[$version].ArcProPatches
              DotnetRuntimeInstallerS3Key = $versionConfig[$version].DotnetRuntimeInstallerS3Key
              DotnetRuntimeInstaller = $versionConfig[$version].DotnetRuntimeInstaller
              InstallLocation = $versionConfig[$version].InstallLocation
              Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
          } | ConvertTo-Json
            Set-Content -Path $configPath -Value $config -Force
            Write-Output "Configuration file created at: $configPath"
          } else {
            throw "Unsupported ArcGIS Pro version: $version. Supported versions: 3.5, 3.6"
          }
          Write-Output "Version defaults configured successfully"
          Stop-Transcript

  - name: InitializeEnvironment
    action: 'aws:runPowerShellScript'
    description: Initialize PowerShell environment and install required modules such as AWS CLI and 7Zip4Powershell
    inputs:
      timeoutSeconds: '900'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          # Function to safely install PowerShell modules
          function Install-ModuleSafely {
            param(
              [string]$ModuleName,
              [string]$MinimumVersion = $null
            )

            try {
              $existing = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue
              if ($existing) {
                # Check if minimum version requirement is met
                if ([string]::IsNullOrWhiteSpace($MinimumVersion)) {
                  Write-Output "$ModuleName module is already installed (Version: $($existing.Version))"
                  return
                } else {
                  try {
                    $minVer = [version]$MinimumVersion
                    if ($existing.Version -ge $minVer) {
                      Write-Output "$ModuleName module is already installed (Version: $($existing.Version), meets minimum: $MinimumVersion)"
                      return
                    } else {
                      Write-Output "$ModuleName module exists (Version: $($existing.Version)) but doesn't meet minimum version: $MinimumVersion"
                    }
                  } catch {
                    Write-Warning "Invalid minimum version format '$MinimumVersion', proceeding with installation"
                  }
                }
              } else {
              Write-Output "$ModuleName module not found, installing..."
              }

              Write-Output "Installing $ModuleName module..."
              Install-Module -Name $ModuleName -Force -AllowClobber -Scope AllUsers -Confirm:$false -ErrorAction Stop
              Write-Output "$ModuleName module installed successfully"
            } catch {
              throw "Failed to install $ModuleName module: $_"
            }
          }

          # Install NuGet provider if not present
          if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
            Write-Output "Installing NuGet provider..."
            try {
              Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -Confirm:$false -ErrorAction Stop
              Write-Output "NuGet provider installed successfully"
            } catch {
              throw "Failed to install NuGet provider: $_"
            }
          } else {
            Write-Output "NuGet provider is already installed"
          }

          # Install required PowerShell modules
          Install-ModuleSafely -ModuleName "7Zip4Powershell"

          # Check and install AWS CLI if not available
          Write-Output "Checking for AWS CLI installation..."
          $awsCliPath = Get-Command aws -ErrorAction SilentlyContinue
          if (-not $awsCliPath) {
            Write-Output "AWS CLI not found. Installing AWS CLI v2..."
            $awsCliInstaller = "$env:TEMP\AWSCLIV2.msi"
            try {
              # Download AWS CLI v2 installer
              $awsCliUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
              [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
              Invoke-WebRequest -Uri $awsCliUrl -OutFile $awsCliInstaller -UseBasicParsing
              Write-Output "Downloaded AWS CLI installer to $${awsCliInstaller}"

              # Install AWS CLI silently
              $installArgs = "/i `"$${awsCliInstaller}`" /quiet /norestart"
              $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow

              if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Output "AWS CLI installed successfully (Exit code: $($process.ExitCode))"
                # Refresh PATH environment variable
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
              } else {
                throw "AWS CLI installation failed with exit code: $($process.ExitCode)"
              }

              # Cleanup installer
              Remove-Item -Path $awsCliInstaller -Force -ErrorAction SilentlyContinue
            } catch {
              $errMsg = $_.Exception.Message
              throw "Failed to install AWS CLI: $${errMsg}"
            }

            # Verify installation
            $awsCliPath = Get-Command aws -ErrorAction SilentlyContinue
            if ($awsCliPath) {
              $awsVersion = aws --version 2>&1
              Write-Output "AWS CLI verified: $${awsVersion}"
            } else {
              throw "AWS CLI installation verification failed - 'aws' command not found in PATH"
            }
          } else {
            $awsVersion = aws --version 2>&1
            Write-Output "AWS CLI is already installed: $${awsVersion}"
          }

          # Validate installation success
          # Refresh module paths - include all standard PowerShell module locations
          $machinePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
          $userPath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "User")
          $systemModules = "C:\Program Files\WindowsPowerShell\Modules"
          $userModules = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
          $programDataModules = "C:\ProgramData\WindowsPowerShell\Modules"

          $env:PSModulePath = "$systemModules;$programDataModules;$userModules;$machinePath;$userPath"
          Write-Output "Updated PSModulePath: $env:PSModulePath"

          # Search for the module in all possible locations
          $possiblePaths = @(
            "C:\Program Files\WindowsPowerShell\Modules\7Zip4Powershell",
            "C:\ProgramData\WindowsPowerShell\Modules\7Zip4Powershell",
            "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\7Zip4Powershell",
            "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\7Zip4Powershell"
          )

          $foundModulePath = $null
          foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
              $foundModulePath = $path
              Write-Output "Found 7Zip4Powershell at: $path"
              break
            }
          }

          # Also try Get-Module after path refresh
          if (-not $foundModulePath) {
            $moduleInfo = Get-Module -Name 7Zip4Powershell -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($moduleInfo) {
              $foundModulePath = $moduleInfo.ModuleBase
              Write-Output "Found 7Zip4Powershell via Get-Module at: $foundModulePath"
            }
          }

          if ($foundModulePath) {
            Import-Module $foundModulePath -Force -ErrorAction Stop
            Write-Output "7Zip4Powershell module loaded successfully from: $foundModulePath"
          } else {
            # Last resort - list what's in the module directories
            Write-Output "Searching for installed modules..."
            Get-ChildItem "C:\Program Files\WindowsPowerShell\Modules" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "  Found: $($_.Name)" }
            throw "7Zip4Powershell module not found after installation. Check if Install-Module succeeded."
          }
          Write-Output "All required modules loaded successfully"
          Stop-Transcript

  - name: InstallNVIDIADrivers
    action: 'aws:runPowerShellScript'
    description: Install NVIDIA drivers on GPU-enabled instances
    inputs:
      timeoutSeconds: '900'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append
          # Check if NVIDIABucket and NVIDIABucketKeyPrefix are null or empty, if so exit gracefully
          if ([string]::IsNullOrWhiteSpace('{{ NVIDIABucket }}') -or [string]::IsNullOrWhiteSpace('{{ NVIDIABucketKeyPrefix }}')) {
            Write-Output "NVIDIABucket or NVIDIABucketKeyPrefix is not specified. Skipping NVIDIA driver installation."
            Stop-Transcript
            exit 0
          }

          # Check if NVIDIA driver is already installed
          $nvidiaSmiPath = "C:\Windows\System32\nvidia-smi.exe"
          if (Test-Path $nvidiaSmiPath) {
            try {
              $nvidiaSmiOutput = & $nvidiaSmiPath --query-gpu=driver_version --format=csv,noheader 2>&1
              if ($LASTEXITCODE -eq 0) {
                Write-Output "NVIDIA driver is already installed. Version: $nvidiaSmiOutput"
                Write-Output "Skipping NVIDIA driver installation."
                Stop-Transcript
                exit 0
              }
            } catch {
              Write-Output "NVIDIA driver check failed, proceeding with installation."
            }
          }


          Write-Output "=== Installing NVIDIA Drivers if applicable ==="
          $Bucket = '{{ NVIDIABucket }}'
          $KeyPrefix = '{{ NVIDIABucketKeyPrefix }}'
          $LocalPath = "{{ ArcProInstallDrive }}\installer\$version\NVIDIA_Drivers"

          if (-not (Test-Path $LocalPath)) {
            New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
          }

          $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1

          # Download NVIDIA driver installer
          Write-Output "Downloading NVIDIA driver from $Bucket with prefix $KeyPrefix ..."
          try {
            foreach ($Object in $Objects) {
              $LocalFileName = $Object.Key
              if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $LocalFileName
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
              }
            }
          } catch {
            throw "Failed to download NVIDIA driver: $_"
          }

          # Find the NVIDIA driver installer executable
          $driverInstallerPath = Get-ChildItem -Path $LocalPath -Filter "*.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName
          if (-not $driverInstallerPath) {
            throw "NVIDIA driver installer executable not found in $LocalPath"
          }
          Write-Output "Found NVIDIA driver installer: $driverInstallerPath"

          # Install NVIDIA driver silently
          Write-Output "Installing NVIDIA driver..."
          try {
            $installArgs = "-s"
            $process = Start-Process -FilePath $driverInstallerPath -ArgumentList $installArgs -Wait -PassThru -NoNewWindow

            if ($process.ExitCode -eq 0) {
              Write-Output "NVIDIA driver installed successfully (Exit code: $($process.ExitCode))"
            } else {
              throw "NVIDIA driver installation failed with exit code: $($process.ExitCode)"
            }

          } catch {
            throw "Failed to install NVIDIA driver: $_"
          }
          New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing
          New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value "1"

          # validate installation
          try {
            $nvidiaSmiOutput = & $nvidiaSmiPath --query-gpu=driver_version --format=csv,noheader 2>&1
            if ($LASTEXITCODE -eq 0) {
              Write-Output "NVIDIA driver installation validated. Version: $nvidiaSmiOutput"
            } else {
              throw "NVIDIA driver validation failed after installation."
            }
          } catch {
            throw "NVIDIA driver validation failed after installation: $_"
          }
          Write-Output "=== NVIDIA Driver installation step completed ==="
          Stop-Transcript

  - name: DownloadAndInstallDotNetRuntime
    action: 'aws:runPowerShellScript'
    description: Download and install .NET Desktop Runtime and Microsoft Edge WebView2 Runtime
    inputs:
      timeoutSeconds: '1200'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          Write-Output "=== Download and Install .net runtime for ArcGIS Pro installation ==="

          if (-not (Test-Path "{{ ArcProInstallDrive }}\installer\$version\logs" )) { New-Item -ItemType Directory -Path "{{ ArcProInstallDrive }}\installer\$version\logs" }

          # Check if the arcgis_pro_install_config.json file exists
          $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
          if (-not (Test-Path $configFilePath)) {
            throw "Configuration file not found at $configFilePath. Ensure previous steps completed successfully."
            exit 1
          }
          # read the configuration file
          $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
          $installS3Bucket = $configContent.InstallS3Bucket
          $dotnetInstallerS3Key = $configContent.DotnetRuntimeInstallerS3Key
          $dotnetInstallers = $configContent.DotnetRuntimeInstaller -split ","
          # Download and install .NET Runtime installers
          foreach ($dotnetInstaller in $dotnetInstallers) {
            Write-Output "Preparing to download and install .NET Runtime installer: $${dotnetInstaller}"
            $resolvedInstallerPath = "{{ ArcProInstallDrive }}\installer\$version\$${dotnetInstaller}"
            if (-not (Test-Path $resolvedInstallerPath)) {
              Write-Output "Downloading $${dotnetInstaller} from S3 bucket '$${installS3Bucket}' with key prefix '$${dotnetInstallerS3Key}'"
              try {
                Copy-S3Object -BucketName $installS3Bucket -Key "$${dotnetInstallerS3Key}/$${dotnetInstaller}" -LocalFile $resolvedInstallerPath -ErrorAction Stop
                Write-Output "Downloaded $${dotnetInstaller} successfully to $${resolvedInstallerPath}"
              } catch {
                $errMsg = $_.Exception.Message
                throw "Failed to download $${dotnetInstaller} from S3: $${errMsg}"
              }
            } else {
              Write-Output "$${dotnetInstaller} already exists at $${resolvedInstallerPath}. Skipping download."
            }
            # Install the runtime - use different arguments for WebView2
            Write-Output "Installing $${dotnetInstaller} from $${resolvedInstallerPath}"
            try {
              if ($dotnetInstaller -like "*WebView2*") {
                # WebView2 uses /silent /install arguments
                Write-Output "Using WebView2 silent install arguments"
                $process = Start-Process -FilePath $resolvedInstallerPath -ArgumentList "/silent /install" -Wait -PassThru -NoNewWindow
              } else {
                # .NET Runtime uses /quiet /norestart arguments
                $process = Start-Process -FilePath $resolvedInstallerPath -ArgumentList "/quiet /norestart" -Wait -PassThru -NoNewWindow
              }

              if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Output "Installed $${dotnetInstaller} successfully (Exit code: $($process.ExitCode))"
              } else {
                Write-Output "Warning: $${dotnetInstaller} returned exit code: $($process.ExitCode)"
              }
            } catch {
              $errMsg = $_.Exception.Message
              throw "Failed to install $${dotnetInstaller}: $${errMsg}"
            }
          }
          Write-Output "=== .net runtime installation completed ==="
          Stop-Transcript

  - name: DownloadAndExtractArcGISPro
    action: 'aws:runPowerShellScript'
    description: Download and extract ArcGIS Pro installer
    inputs:
      timeoutSeconds: '1800'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          Write-Output "=== Download ArcGIS Pro installater ==="
          # read the configuration file
          $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
          if (-not (Test-Path $configFilePath)) {
            throw "Configuration file not found at $configFilePath. Ensure previous steps completed successfully."
            exit 1
          }
          $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
          $arcProInstallerS3Key = $configContent.ArcProInstallerS3Key
          $installS3Bucket = $configContent.InstallS3Bucket
          $version = $configContent.Version
          $installerPath = "{{ ArcProInstallDrive }}\installer\$version"

          if (-not (Test-Path "$installerPath" )) { New-Item -ItemType Directory -Path "$installerPath" }
          $resolvedInstallerPath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_installer.exe"

          Write-Output "Preparing ArcGIS Pro version: $version"
          Write-Output "Using installer path: $installerPath"

          if (-not (Test-Path $resolvedInstallerPath)) {
            Write-Output "Downloading ArcGIS Pro installer from S3 bucket '$installS3Bucket' with key prefix '$arcProInstallerS3Key'"
            try {
              Copy-S3Object -BucketName $installS3Bucket -Key "$arcProInstallerS3Key" -LocalFile $resolvedInstallerPath -ErrorAction Stop
              Write-Output "Downloaded ArcGIS Pro installer successfully to $resolvedInstallerPath"
            } catch {
              throw "Failed to download ArcGIS Pro installer from S3: $_"
            }
          } else {
            Write-Output "ArcGIS Pro installer already exists at $resolvedInstallerPath. Skipping download."
          }

          $extractFolder = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_extracted"
          if (-not (Test-Path "$extractFolder" )) { New-Item -ItemType Directory -Path "$extractFolder" }

          # Check if already extracted
          $existingExtraction = Get-ChildItem -Path $extractFolder -Filter "*.msi" -Recurse | Select-Object -First 1
          if ($existingExtraction) {
            Write-Output "ArcGIS Pro already extracted to: $extractFolder"
          } else {
            Write-Output "Extracting ArcGIS Pro installer: $($resolvedInstallerPath)"
            try {
              # Import 7Zip4Powershell module - search all possible locations
              $possiblePaths = @(
                "C:\Program Files\WindowsPowerShell\Modules\7Zip4Powershell",
                "C:\ProgramData\WindowsPowerShell\Modules\7Zip4Powershell",
                "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\7Zip4Powershell"
              )

              $foundModulePath = $null
              foreach ($path in $possiblePaths) {
                if (Test-Path $path) {
                  $foundModulePath = $path
                  break
                }
              }

              if (-not $foundModulePath) {
                $moduleInfo = Get-Module -Name 7Zip4Powershell -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($moduleInfo) {
                  $foundModulePath = $moduleInfo.ModuleBase
                }
              }

              if ($foundModulePath) {
                Import-Module $foundModulePath -Force -ErrorAction Stop
                Write-Output "7Zip4Powershell loaded from: $foundModulePath"
              } else {
                throw "7Zip4Powershell module not found"
              }

              Expand-7Zip -ArchiveFileName $resolvedInstallerPath -TargetPath $extractFolder -ErrorAction Stop
              Write-Output "ArcGIS Pro installer extracted successfully"
            } catch {
              throw "Failed to extract ArcGIS Pro installer: $_"
            }
          }

          # verify extraction
          $msiFile = Get-ChildItem -Path $extractFolder -Filter "*.msi" -Recurse | Select-Object -First 1
          if (-not $msiFile) {
            throw "Extraction failed: ArcGIS Pro MSI file not found in $extractFolder"
          } else {
            Write-Output "Verified extraction: Found ArcGIS Pro MSI at $($msiFile.FullName)"
          }
          Write-Output "=== Download ArcGIS Pro Installer step completed ==="
          Stop-Transcript

  - name: InstallArcGISPro
    action: 'aws:runPowerShellScript'
    description: Install ArcGIS Pro with specified configuration
    inputs:
      timeoutSeconds: '2400'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          # Check if the installed version matches the target version
          # Find ArcGIS Pro in installed programs
          $uninstallKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
          )

          $arcGISPro = Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "ArcGIS Pro*" } |
            Select-Object -First 1

          if (-not $arcGISPro) {
            Write-Output "No existing ArcGIS Pro installation found. Proceeding with fresh install."
          } else {
            $installedVersion = $arcGISPro.DisplayVersion
            $productCode = $arcGISPro.PSChildName
            $displayName = $arcGISPro.DisplayName

            Write-Output "Found existing installation:"
            Write-Output "  Name: $displayName"
            Write-Output "  Version: $installedVersion"
            Write-Output "  Product Code: $productCode"

            # Check if the installed version matches the target version
            if ($installedVersion -eq '{{ ArcProVersion }}' -or $installedVersion -like '{{ ArcProVersion }}.*') {
              Write-Output "Installed version ($installedVersion) matches target version ({{ ArcProVersion }}). skipping install."
              Stop-Transcript
              exit 0
            } else {
              Write-Output "Installed version ($installedVersion) differs from target version ({{ ArcProVersion }}).Proceeding with upgrade."
            }

          }

          Write-Output "=== Installing ArcGIS Pro version: $version ==="

          # Find ArcGIS Pro MSI file
          $extractFolder = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_extracted"
          $arcProMsiFile = Get-ChildItem -Path $extractFolder -Filter "*.msi" -Recurse | Select-Object -First 1
          $installFolder = "{{ ArcProInstallDrive }}\ArcGIS\Pro"
          if (-not $arcProMsiFile) {
            throw "ArcGIS Pro MSI file not found in: $extractFolder"
          }

          Write-Output "Found ArcGIS Pro MSI: $($arcProMsiFile.FullName)"

          # Build installation arguments based on authorization type
          $baseArgs = @(
            "/i", "`"$($arcProMsiFile.FullName)`""
            "ALLUSERS=1"
            "ACCEPTEULA=YES"
            "SOFTWARE_CLASS=Professional"
            "AUTHORIZATION_TYPE={{ AuthorizationType }}"
            "INSTALLDIR=`"$installFolder`""
            "PORTAL_LIST=`"{{ PortalList }}`""
            "ENABLE_ERROR_REPORTS=0"
            "ENABLEEUEI=0"
            "/qn"
            "/l*v", "`"{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro.log`""
          )

          # Add authorization-specific parameters
          switch ("{{ AuthorizationType }}") {
            "NAMED_USER" {
              $baseArgs += "LICENSE_URL=`"{{ PortalLicenseURL }}`""
              Write-Output "Configuring for Named User licensing with Portal: {{ PortalLicenseURL }}"
            }
            "SINGLE_USE" {
              if ([string]::IsNullOrWhiteSpace("{{ ArcProLicenseFile }}")) {
                throw "ArcProLicenseFile parameter is required for SINGLE_USE authorization"
              }
              $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
              $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
              $installS3Bucket = $configContent.InstallS3Bucket
              $singleUseLicenseFile = "{{ ArcProInstallDrive }}\installer\$version\ArcProSingleUseLicense.prvc"
              if (-not (Test-Path $singleUseLicenseFile)) {
                Write-Output "Downloading ArcGIS Pro single use license file from S3 bucket '$installS3Bucket' with key prefix '{{ ArcProLicenseFile }}'"
                try {
                  Copy-S3Object -BucketName $installS3Bucket -Key "{{ ArcProLicenseFile }}" -LocalFile $singleUseLicenseFile -ErrorAction Stop
                  Write-Output "Downloaded ArcGIS Pro single use license file '{{ ArcProLicenseFile }}' successfully to $singleUseLicenseFile"
                } catch {
                  throw "Failed to download ArcGIS Pro single use license file '{{ ArcProLicenseFile }}' from S3: $_"
                }
              } else {
                Write-Output "ArcGIS Pro single use license file '{{ ArcProLicenseFile }}' already exists at $singleUseLicenseFile. Skipping download."
              }

              $baseArgs += "ESRI_LICENSE_HOST=`"{{ ArcProLicenseFile }}`""
              Write-Output "Configuring for Single Use licensing with ArcGIS Pro license file: {{ ArcProLicenseFile }}"
            }
            default {
              throw "Invalid AuthorizationType: {{ AuthorizationType }}"
            }
          }

          # Execute installation
          Write-Output "Installing ArcGIS Pro with arguments: $($baseArgs -join ' ')"
          try {
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $baseArgs -Wait -PassThru

            if ($process.ExitCode -eq 0) {
              Write-Output "ArcGIS Pro installed successfully"
            } elseif ($process.ExitCode -eq 3010) {
              Write-Output "ArcGIS Pro installed successfully (reboot required)"
            } else {
              $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
              $logContent = if (Test-Path $logFile) { Get-Content $logFile -Tail 20 | Out-String } else { "Log file not available" }
              throw "ArcGIS Pro installation failed with exit code $($process.ExitCode). Log excerpt: $logContent"
            }
          } catch {
            throw "Failed to install ArcGIS Pro: $_"
          }
          if ("{{ AuthorizationType }}" -eq 'SINGLE_USE') {
            Write-Output "Authorizing Single Use license..."

            if (Test-Path $singleUseLicenseFile) {
              Write-Output "Single Use license file found at: $singleUseLicenseFile"
              if (Test-Path "{{ ArcProInstallDrive }}\ArcGIS\Pro\bin\SoftwareAuthorizationPro.exe") {
                $authExe = "{{ ArcProInstallDrive }}\ArcGIS\Pro\bin\SoftwareAuthorizationPro.exe"
                $authArgs = @(
                  "/s"
                  "/LIF", "`"$singleUseLicenseFile`""
                )
                Write-Output "Running authorization command: $($authExe) $($authArgs -join ' ')"
                try {
                  $authProcess = Start-Process -FilePath $authExe -ArgumentList $authArgs -Wait -PassThru
                  if ($authProcess.ExitCode -eq 0) {
                    Write-Output "ArcGIS Pro Single Use license authorized successfully"
                  } else {
                    throw "ArcGIS Pro Single Use license authorization failed with exit code $($authProcess.ExitCode)"
                  }
                } catch {
                  throw "Failed to authorize ArcGIS Pro Single Use license: $_"
                }
              } else {
                throw "SoftwareAuthorizationPro.exe not found at expected location: {{ ArcProInstallDrive }}\ArcGIS\Pro\bin\SoftwareAuthorizationPro.exe"
              }
            } else {
              throw "Single Use license file not found at expected location: $singleUseLicenseFile"
            }
          }
          Write-Output "=== Install step completed ==="
          Stop-Transcript

  - name: DownloadandInstallArcGISProPatches
    action: 'aws:runPowerShellScript'
    description: Download and install ArcGIS Pro patches
    inputs:
      timeoutSeconds: '1800'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append
          $successCount = 0
          $failCount = 0

          # Find ArcGIS Pro in installed programs
          $uninstallKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
          )

          $arcGISPro = Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "ArcGIS Pro*" } |
            Select-Object -First 1

          if (-not $arcGISPro) {
            Write-Output "No existing ArcGIS Pro installation found. Skipping the patch installation."
            Stop-Transcript
            exit 0
          }
          # Check if the arcgis_pro_install_config.json file exists
          $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
          if (-not (Test-Path $configFilePath)) {
            throw "Configuration file not found at $configFilePath. Ensure previous steps completed successfully."
            exit 1
          }
          # read the configuration file
          $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
          $installS3Bucket = $configContent.InstallS3Bucket
          $arcProPatchesS3Key = $configContent.ArcProPatchesS3Key
          $arcProPatches = $configContent.ArcProPatches

          # download patches if specified
          if (-not [string]::IsNullOrWhiteSpace($arcProPatches))
          {
            $patches = $arcProPatches -split ","
            foreach ($patch in $patches) {
              $resolvedPatchPath = "{{ ArcProInstallDrive }}\installer\$version\$patch"
              if (-not (Test-Path $resolvedPatchPath)) {
                Write-Output "Downloading ArcGIS Pro patch '$patch' from S3 bucket '$installS3Bucket' with key prefix '$arcProPatchesS3Key'"
                try {
                  Copy-S3Object -BucketName $installS3Bucket -Key "$arcProPatchesS3Key/$patch" -LocalFile $resolvedPatchPath -ErrorAction Stop
                  Write-Output "Downloaded ArcGIS Pro patch '$patch' successfully to $resolvedPatchPath"
                } catch {
                  throw "Failed to download ArcGIS Pro patch '$patch' from S3: $_"
                }
              } else {
                Write-Output "ArcGIS Pro patch '$patch' already exists at $resolvedPatchPath. Skipping download."
              }
              # Install the patch
              Write-Output "Installing patch: $patch"
              try {
                $patchArgs = @(
                  "/update", "`"$resolvedPatchPath`""
                  "/quiet"
                  "/l*v", "`"{{ ArcProInstallDrive }}\installer\$version\logs\$patch.log`""
                )
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $patchArgs -Wait -PassThru
                if ($process.ExitCode -eq 0) {
                  Write-Output "Patch '$patch' installed successfully"
                  $successCount++
                } elseif ($process.ExitCode -eq 3010) {
                  Write-Output "Patch '$patch' installed successfully (reboot may be required)"
                  $successCount++
                } else {
                  Write-Warning "Patch '$patch' installation failed with exit code $($process.ExitCode)"
                  $failCount++
                }
              } catch {
              Write-Warning "Failed to install patch '$patch': $_"
              $failCount++
              }
            }

            Write-Output "Patch installation summary: $successCount successful, $failCount failed"
            Stop-Transcript
          }

  - name: DownloadGeodataSentry
    action: 'aws:runPowerShellScript'
    description: Download Geodata Sentry installer if specified
    inputs:
      timeoutSeconds: '900'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          # Check if GeodataSentryInstallerS3Key is null or empty, if so exit gracefully
          if ([string]::IsNullOrWhiteSpace('{{ GeodataSentryInstallerS3Key }}')) {
            Write-Output "GeodataSentryInstallerS3Key is not specified. Skipping Geodata Sentry download."
            Stop-Transcript
            exit 0
          }
          if (-not (Test-Path "{{ ArcProInstallDrive }}\installer" )) { New-Item -ItemType Directory -Path "{{ ArcProInstallDrive }}\installer" }

          # Check if the Geodata Sentry installer folder exists and contains files, if not, download from S3 bucket
          $FolderPath = "{{ ArcProInstallDrive }}\installer\{{ GeodataSentryInstallerS3Key }}" -replace '/', '\'

          if (Test-Path $FolderPath) {
            $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue
            if ($files -and $files.Count -gt 0) {
              Write-Output "Folder $FolderPath already exists and contains $($files.Count) file(s). Skipping download."
              Stop-Transcript
              exit 0
            } else {
              Write-Output "Folder $FolderPath exists but is empty. Proceeding with download from S3."
            }
          } else {
            Write-Output "Folder $FolderPath does not exist. Creating folder and Proceeding with download from S3."
            New-Item -ItemType Directory -Path $FolderPath -Force
          }
          # Check if the arcgis_pro_install_config.json file exists
          $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
          if (-not (Test-Path $configFilePath)) {
            throw "Configuration file not found at $configFilePath. Ensure previous steps completed successfully."
            exit 1
          }
          # read the configuration file
          $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
          $installS3Bucket = $configContent.InstallS3Bucket
          try {
                # Use AWS CLI instead of Copy-S3Object to avoid access violation errors
                Write-Output "Downloading Geodata Sentry from S3 bucket '$${installS3Bucket}' with key prefix '{{ GeodataSentryInstallerS3Key }}'"
                $s3Uri = "s3://$${installS3Bucket}/{{ GeodataSentryInstallerS3Key }}"
                $awsResult = aws s3 cp $s3Uri $FolderPath --recursive 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "AWS CLI failed with exit code $${LASTEXITCODE}: $${awsResult}"
                }
                Write-Output "Downloaded Geodata Sentry successfully to $${FolderPath}"
          } catch {
                $errMsg = $_.Exception.Message
                throw "Failed to download files from S3 bucket '$${installS3Bucket}' to $${FolderPath}: $${errMsg}"
          }
          Write-Output "=== Geodata Sentry download step completed ==="
          Stop-Transcript

  - name: DownloadUDCTools
    action: 'aws:runPowerShellScript'
    description: Download UDC Tools installer if specified
    inputs:
      timeoutSeconds: '900'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          # Check if UDCtoolInstallerS3Key is null or empty, if so exit gracefully
          if ([string]::IsNullOrWhiteSpace('{{ UDCtoolInstallerS3Key }}')) {
            Write-Output "UDCtoolInstallerS3Key is not specified. Skipping UDC Tool download."
            Stop-Transcript
            exit 0
          }
          if (-not (Test-Path "{{ ArcProInstallDrive }}\installer" )) { New-Item -ItemType Directory -Path "{{ ArcProInstallDrive }}\installer" }

          # Check if the UDC Tools installer folder exists and contains files, if not, download from S3 bucket
          $FolderPath = "{{ ArcProInstallDrive }}\installer\{{ UDCtoolInstallerS3Key }}" -replace '/', '\'

          if (Test-Path $FolderPath) {
            $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue
            if ($files -and $files.Count -gt 0) {
              Write-Output "Folder $FolderPath already exists and contains $($files.Count) file(s). Skipping download."
              Stop-Transcript
              exit 0
            } else {
              Write-Output "Folder $FolderPath exists but is empty. Proceeding with download from S3."
            }
          } else {
            Write-Output "Folder $FolderPath does not exist. Creating folder and Proceeding with download from S3."
            New-Item -ItemType Directory -Path $FolderPath -Force
          }
          # Check if the arcgis_pro_install_config.json file exists
          $configFilePath = "{{ ArcProInstallDrive }}\installer\$version\arcgis_pro_install_config.json"
          if (-not (Test-Path $configFilePath)) {
            throw "Configuration file not found at $configFilePath. Ensure previous steps completed successfully."
            exit 1
          }
          # read the configuration file
          $configContent = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
          $installS3Bucket = $configContent.InstallS3Bucket
          try {
                # Use AWS CLI instead of Copy-S3Object to avoid access violation errors
                Write-Output "Downloading UDC Tools from S3 bucket '$${installS3Bucket}' with key prefix '{{ UDCtoolInstallerS3Key }}'"
                $s3Uri = "s3://$${installS3Bucket}/{{ UDCtoolInstallerS3Key }}"
                $awsResult = aws s3 cp $s3Uri $FolderPath --recursive 2>&1
                if ($LASTEXITCODE -ne 0) {
                    throw "AWS CLI failed with exit code $${LASTEXITCODE}: $${awsResult}"
                }
                Write-Output "Downloaded UDC Tools successfully to $${FolderPath}"
          } catch {
                $errMsg = $_.Exception.Message
                throw "Failed to download files from S3 bucket '$${installS3Bucket}' to $${FolderPath}: $${errMsg}"
          }
          Write-Output "=== UDC Tool download step completed ==="
          Stop-Transcript

  - name: FinalizeInstallation
    action: 'aws:runPowerShellScript'
    description: Perform post-installation cleanup and verification
    inputs:
      timeoutSeconds: '300'
      runCommand:
        - |
          # Initialize logging and error handling
          $ErrorActionPreference = "Stop"
          $ProgressPreference = "SilentlyContinue"
          $version = '{{ ArcProVersion }}'
          Set-TimeZone -Id "Pacific Standard Time"

          $logFile = "{{ ArcProInstallDrive }}\installer\$version\logs\ArcGISPro_Install.log"
          if (-not (Test-Path $logFile)) {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
          }
          Start-Transcript -Path $logFile -Append

          Write-Output "=== ArcGIS Pro Installation Finalization ==="

          # Verify ArcGIS Pro installation
          $arcgisProPath = "{{ ArcProInstallDrive }}\ArcGIS\Pro"
          $arcgisProExe = Join-Path $arcgisProPath "bin\ArcGISPro.exe"

          if (Test-Path $arcgisProExe) {
            try {
              $installedVersion = (Get-ItemProperty $arcgisProExe).VersionInfo.ProductVersion
              Write-Output "✓ ArcGIS Pro installation verified at: $arcgisProPath"
              Write-Output "  Version: $installedVersion"
            } catch {
              Write-Output "✓ ArcGIS Pro executable found at: $arcgisProExe"
            }
          } else {
            Write-Warning "✗ ArcGIS Pro executable not found at: $arcgisProExe"
          }

          # Check for log files
          $logFiles = Get-ChildItem -Path "{{ ArcProInstallDrive }}\installer\$version\logs" -Filter "*.log" -ErrorAction SilentlyContinue
          if ($logFiles) {
            Write-Output "Installation log files:"
            foreach ($log in $logFiles) {
              Write-Output "  - $($log.Name) ($([math]::Round($log.Length/1KB, 1)) KB)"
            }
          }
          else {
            Write-Warning "No installation log files found in {{ ArcProInstallDrive }}\installer\$version\logs"
          }
          Write-Output "=== Installation Complete ==="
          Stop-Transcript
