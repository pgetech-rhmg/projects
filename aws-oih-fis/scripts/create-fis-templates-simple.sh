#!/bin/bash

# Simple FIS template creation script
# Creates experiment templates using direct CLI commands

set -e

ACCOUNT_ID="302263046280"
REGION="us-west-2"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/FISExperimentRole"
LOG_GROUP_ARN="arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:/aws/fis/experiments:*"

echo "=========================================="
echo "Creating FIS Experiment Templates"
echo "=========================================="
echo ""
echo "Account: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo ""

# Create Primary template
echo "1) Creating Primary DB Failover template..."
echo ""

# Note: FIS doesn't support runtime parameters in the traditional sense
# The AZ must be specified in the filter, so we'll create templates that target specific AZs
# For runtime flexibility, we'll need to use separate templates or update the experiment

PRIMARY_ID=$(aws fis create-experiment-template \
  --description "Stop Primary SQL Server instances in specified AZ" \
  --targets "{\"primaryDBInstances\":{\"resourceType\":\"aws:ec2:instance\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISDBRole\":\"Primary\"},\"filters\":[{\"path\":\"State.Name\",\"values\":[\"running\"]}]}}" \
  --actions "{\"stopInstances\":{\"actionId\":\"aws:ec2:stop-instances\",\"description\":\"Stop primary instances\",\"parameters\":{\"startInstancesAfterDuration\":\"PT5M\"},\"targets\":{\"Instances\":\"primaryDBInstances\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Primary-Stop,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Primary template created: ${PRIMARY_ID}"
echo ""

# Create Secondary template
echo "2) Creating Secondary DB Isolation template..."
echo ""

SECONDARY_ID=$(aws fis create-experiment-template \
  --description "Stop Secondary SQL Server instances in specified AZ" \
  --targets "{\"secondaryDBInstances\":{\"resourceType\":\"aws:ec2:instance\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISDBRole\":\"Secondary\"},\"filters\":[{\"path\":\"State.Name\",\"values\":[\"running\"]}]}}" \
  --actions "{\"stopInstances\":{\"actionId\":\"aws:ec2:stop-instances\",\"description\":\"Stop secondary instances\",\"parameters\":{\"startInstancesAfterDuration\":\"PT5M\"},\"targets\":{\"Instances\":\"secondaryDBInstances\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Secondary-Stop,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Secondary template created: ${SECONDARY_ID}"
echo ""

echo "=========================================="
echo "Templates Created Successfully!"
echo "=========================================="
echo ""
echo "Primary Template ID: ${PRIMARY_ID}"
echo "  - Targets: Instances tagged FISTarget=True AND FISDBRole=Primary"
echo "  - Action: Stop for 5 minutes"
echo ""
echo "Secondary Template ID: ${SECONDARY_ID}"
echo "  - Targets: Instances tagged FISTarget=True AND FISDBRole=Secondary"
echo "  - Action: Stop for 5 minutes"
echo ""
echo "NOTE: These templates will target ALL instances with the required tags,"
echo "regardless of AZ. The safety comes from the tag requirements."
echo ""
echo "To run an experiment:"
echo "  aws fis start-experiment --experiment-template-id ${PRIMARY_ID}"
echo ""
echo "Or use the interactive script:"
echo "  ./scripts/run-fis-experiment-simple.sh"
