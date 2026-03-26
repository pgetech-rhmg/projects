#!/bin/bash

# Create FIS EBS volume I/O pause experiment templates
# Tests SQL Server resilience to storage disruption

set -e

ACCOUNT_ID="302263046280"
REGION="us-west-2"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/FISExperimentRole"
LOG_GROUP_ARN="arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:/aws/fis/experiments:*"

echo "=========================================="
echo "Creating FIS EBS I/O Pause Templates"
echo "=========================================="
echo ""
echo "Account: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo ""

# Create EBS I/O pause experiment for Primary DB volumes
echo "1) Creating Primary DB EBS I/O Pause template..."
echo ""

# Target: ALL EBS volumes tagged FISTarget=True AND FISEBSTarget=True AND FISDBRole=Primary
PRIMARY_EBS_ID=$(aws fis create-experiment-template \
  --description "Pause I/O on EBS volumes attached to Primary SQL Server instances" \
  --targets "{\"primaryDBVolumes\":{\"resourceType\":\"aws:ec2:ebs-volume\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISEBSTarget\":\"True\",\"FISDBRole\":\"Primary\"}}}" \
  --actions "{\"pauseVolumeIO\":{\"actionId\":\"aws:ebs:pause-volume-io\",\"description\":\"Pause I/O on primary DB volumes for 5 minutes\",\"parameters\":{\"duration\":\"PT5M\"},\"targets\":{\"Volumes\":\"primaryDBVolumes\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Primary-EBS-IO-Pause,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Primary EBS I/O pause template created: ${PRIMARY_EBS_ID}"
echo ""

# Create EBS I/O pause experiment for Secondary DB volumes
echo "2) Creating Secondary DB EBS I/O Pause template..."
echo ""

SECONDARY_EBS_ID=$(aws fis create-experiment-template \
  --description "Pause I/O on EBS volumes attached to Secondary SQL Server instances" \
  --targets "{\"secondaryDBVolumes\":{\"resourceType\":\"aws:ec2:ebs-volume\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISEBSTarget\":\"True\",\"FISDBRole\":\"Secondary\"}}}" \
  --actions "{\"pauseVolumeIO\":{\"actionId\":\"aws:ebs:pause-volume-io\",\"description\":\"Pause I/O on secondary DB volumes for 5 minutes\",\"parameters\":{\"duration\":\"PT5M\"},\"targets\":{\"Volumes\":\"secondaryDBVolumes\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Secondary-EBS-IO-Pause,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Secondary EBS I/O pause template created: ${SECONDARY_EBS_ID}"
echo ""

echo "=========================================="
echo "Templates Created Successfully!"
echo "=========================================="
echo ""
echo "Primary EBS I/O Pause Template ID: ${PRIMARY_EBS_ID}"
echo "  Targets: EBS volumes with tags FISTarget=True, FISEBSTarget=True, FISDBRole=Primary"
echo "  Action: Pause I/O for 5 minutes"
echo ""
echo "Secondary EBS I/O Pause Template ID: ${SECONDARY_EBS_ID}"
echo "  Targets: EBS volumes with tags FISTarget=True, FISEBSTarget=True, FISDBRole=Secondary"
echo "  Action: Pause I/O for 5 minutes"
echo ""
echo "SAFETY: Only EBS volumes tagged with ALL THREE tags will be affected:"
echo "  - FISTarget=True"
echo "  - FISEBSTarget=True"
echo "  - FISDBRole=Primary OR FISDBRole=Secondary"
echo "WARNING: This will pause I/O on tagged volumes for 5 minutes."
echo "SQL Server will experience storage timeouts during the pause."
echo ""
echo "IMPORTANT: You must tag your EBS volumes with ALL THREE tags:"
echo "  - FISTarget=True"
echo "  - FISEBSTarget=True"
echo "  - FISDBRole=Primary (or Secondary, depending on the instance role)"
echo ""
echo "To run an experiment:"
echo "  aws fis start-experiment --experiment-template-id ${PRIMARY_EBS_ID}"
echo ""
