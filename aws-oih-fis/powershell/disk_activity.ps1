# Disk I/O Activity Generator for FIS Testing
# Generates continuous read/write activity to make EBS I/O pause obvious

param(
    [int]$DurationSeconds = 600,  # Run for 10 minutes by default
    [int]$FileSizeMB = 50,        # Size of test files to write
    [string]$TestPath = "TEMP\FIS_Test"  # Base path for test files (relative to drive root)
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Disk I/O Activity Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Duration: $DurationSeconds seconds"
Write-Host "  Test File Size: $FileSizeMB MB"
Write-Host "  Test Path: $TestPath"
Write-Host ""

# Function to generate disk activity on a specific drive
function Generate-DiskActivity {
    param(
        [string]$DriveLetter,
        [int]$FileSizeMB,
        [string]$BaseTestPath
    )

    $testDir = "${DriveLetter}:\$BaseTestPath"

    # Create test directory if it doesn't exist
    if (-not (Test-Path $testDir)) {
        New-Item -Path $testDir -ItemType Directory -Force | Out-Null
        Write-Host "Created test directory: $testDir" -ForegroundColor Green
    }

    $testFile = Join-Path $testDir "test_$(Get-Random).dat"

    try {
        # Write test - Create a file with random data
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ${DriveLetter}: Writing $FileSizeMB MB..." -ForegroundColor White
        $buffer = New-Object byte[] (1MB)
        (New-Object Random).NextBytes($buffer)

        $stream = [System.IO.File]::Create($testFile)
        for ($i = 0; $i -lt $FileSizeMB; $i++) {
            $stream.Write($buffer, 0, $buffer.Length)
        }
        $stream.Close()

        # Read test - Read the entire file back
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ${DriveLetter}: Reading $FileSizeMB MB..." -ForegroundColor White
        $readBuffer = [System.IO.File]::ReadAllBytes($testFile)

        # Clean up
        Remove-Item $testFile -Force

        return $true
    }
    catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ${DriveLetter}: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Get all fixed drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.Root -match '^[A-Z]:\\$' -and
    (Get-Volume -DriveLetter $_.Name -ErrorAction SilentlyContinue).DriveType -eq 'Fixed'
}

Write-Host "Detected Fixed Drives:" -ForegroundColor Yellow
foreach ($drive in $drives) {
    $volume = Get-Volume -DriveLetter $drive.Name
    $sizeGB = [math]::Round($volume.Size / 1GB, 2)
    $freeGB = [math]::Round($volume.SizeRemaining / 1GB, 2)
    Write-Host "  $($drive.Name): $sizeGB GB total, $freeGB GB free" -ForegroundColor Cyan
}
Write-Host ""

# Start timestamp
$startTime = Get-Date
$endTime = $startTime.AddSeconds($DurationSeconds)

Write-Host "Starting continuous disk activity until $(Get-Date $endTime -Format 'HH:mm:ss')..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop early" -ForegroundColor Yellow
Write-Host ""

$iteration = 0
while ((Get-Date) -lt $endTime) {
    $iteration++
    Write-Host "========== Iteration $iteration - $(Get-Date -Format 'HH:mm:ss') ==========" -ForegroundColor Cyan

    foreach ($drive in $drives) {
        $success = Generate-DiskActivity -DriveLetter $drive.Name -FileSizeMB $FileSizeMB -BaseTestPath $TestPath

        if (-not $success) {
            Write-Host "  WARNING: I/O operation failed on drive $($drive.Name)!" -ForegroundColor Red
            Write-Host "  This may indicate EBS I/O pause is active!" -ForegroundColor Red
        }

        Start-Sleep -Milliseconds 500
    }

    Write-Host ""

    # Check if we should continue
    $remaining = ($endTime - (Get-Date)).TotalSeconds
    if ($remaining -gt 0) {
        Write-Host "Time remaining: $([math]::Round($remaining, 0)) seconds" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Disk Activity Generation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Cleanup test directories
Write-Host ""
Write-Host "Cleaning up test directories..." -ForegroundColor Yellow
foreach ($drive in $drives) {
    $testDir = "${drive}:\$TestPath"
    if (Test-Path $testDir) {
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed: $testDir" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
