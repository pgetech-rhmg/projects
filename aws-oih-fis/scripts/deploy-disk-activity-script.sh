#!/bin/bash

# Deploy disk_activity.ps1 to a Windows instance via SSM

set -e

INSTANCE_ID="${1}"
SCRIPT_PATH="../powershell/disk_activity.ps1"

if [ -z "$INSTANCE_ID" ]; then
    echo "Usage: $0 <instance-id>"
    echo ""
    echo "Example: $0 i-050f31ca3a6933bec"
    exit 1
fi

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Script not found at $SCRIPT_PATH"
    exit 1
fi

echo "=========================================="
echo "Deploying Disk Activity Script to Instance"
echo "=========================================="
echo ""
echo "Instance ID: ${INSTANCE_ID}"
echo "Script: ${SCRIPT_PATH}"
echo ""

# Read the script content and base64 encode it to avoid escaping issues
SCRIPT_CONTENT=$(cat "$SCRIPT_PATH" | base64)

# Send command to decode and write the file
COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunPowerShellScript" \
    --parameters "commands=[
        'if (-not (Test-Path C:\\temp)) { New-Item -Path C:\\temp -ItemType Directory -Force | Out-Null }',
        '\$scriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(\"$SCRIPT_CONTENT\"))',
        '\$scriptContent | Out-File -FilePath C:\\temp\\disk_activity.ps1 -Encoding UTF8',
        'Write-Host \"Script deployed to C:\\temp\\disk_activity.ps1\"',
        'Write-Host \"\"',
        'Write-Host \"To run the script:\"',
        'Write-Host \"  cd C:\\temp\"',
        'Write-Host \"  .\\disk_activity.ps1\"',
        'Write-Host \"\"',
        'Write-Host \"Or with custom parameters:\"',
        'Write-Host \"  .\\disk_activity.ps1 -DurationSeconds 300 -FileSizeMB 100\"'
    ]" \
    --comment "Deploy disk I/O activity generator script" \
    --query 'Command.CommandId' \
    --output text)

echo "Command ID: ${COMMAND_ID}"
echo ""
echo "Waiting for command to complete..."
echo ""

# Wait for command to complete
aws ssm wait command-executed \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID"

# Get command output
echo "Command Output:"
echo "=========================================="
aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --query 'StandardOutputContent' \
    --output text

echo ""
echo "=========================================="
echo "✓ Script deployed successfully!"
echo "=========================================="
echo ""
echo "The script is now available at: C:\\temp\\disk_activity.ps1"
echo ""
echo "To run it via SSM:"
echo "  aws ssm start-session --target ${INSTANCE_ID}"
echo "  cd C:\\temp"
echo "  .\\disk_activity.ps1"
echo ""
