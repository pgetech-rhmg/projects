#!/bin/bash

# Create FIS network disruption experiment templates
# Tests SQL Server resilience to network connectivity issues

set -e

ACCOUNT_ID="302263046280"
REGION="us-west-2"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/FISExperimentRole"
LOG_GROUP_ARN="arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:/aws/fis/experiments:*"

echo "=========================================="
echo "Creating FIS Network Disruption Templates"
echo "=========================================="
echo ""
echo "Account: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo ""

# Create network disruption experiment for Primary DB
echo "1) Creating Primary DB Network Disruption template..."
echo ""

PRIMARY_NET_ID=$(aws fis create-experiment-template \
  --description "Disrupt network connectivity to Primary SQL Server instances" \
  --targets "{\"primaryDBInstances\":{\"resourceType\":\"aws:ec2:instance\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISDBRole\":\"Primary\"},\"filters\":[{\"path\":\"State.Name\",\"values\":[\"running\"]}]}}" \
  --actions "{\"disruptConnectivity\":{\"actionId\":\"aws:network:disrupt-connectivity\",\"description\":\"Block all network connectivity to primary instance for 5 minutes\",\"parameters\":{\"duration\":\"PT5M\",\"scope\":\"all\"},\"targets\":{\"Instances\":\"primaryDBInstances\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Primary-Network-Disrupt,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Primary network disruption template created: ${PRIMARY_NET_ID}"
echo ""

# Create network disruption experiment for Secondary DB
echo "2) Creating Secondary DB Network Disruption template..."
echo ""

SECONDARY_NET_ID=$(aws fis create-experiment-template \
  --description "Disrupt network connectivity to Secondary SQL Server instances" \
  --targets "{\"secondaryDBInstances\":{\"resourceType\":\"aws:ec2:instance\",\"selectionMode\":\"ALL\",\"resourceTags\":{\"FISTarget\":\"True\",\"FISDBRole\":\"Secondary\"},\"filters\":[{\"path\":\"State.Name\",\"values\":[\"running\"]}]}}" \
  --actions "{\"disruptConnectivity\":{\"actionId\":\"aws:network:disrupt-connectivity\",\"description\":\"Block all network connectivity to secondary instance for 5 minutes\",\"parameters\":{\"duration\":\"PT5M\",\"scope\":\"all\"},\"targets\":{\"Instances\":\"secondaryDBInstances\"}}}" \
  --stop-conditions "[{\"source\":\"none\"}]" \
  --role-arn "${ROLE_ARN}" \
  --log-configuration "{\"cloudWatchLogsConfiguration\":{\"logGroupArn\":\"${LOG_GROUP_ARN}\"},\"logSchemaVersion\":2}" \
  --tags "Name=OIH-Secondary-Network-Disrupt,Environment=DEV,TestType=HA-DR" \
  --query 'experimentTemplate.id' \
  --output text)

echo "✓ Secondary network disruption template created: ${SECONDARY_NET_ID}"
echo ""

echo "=========================================="
echo "Templates Created Successfully!"
echo "=========================================="
echo ""
echo "Primary Network Disruption Template ID: ${PRIMARY_NET_ID}"
echo "  Targets: Primary instances (FISTarget=True AND FISDBRole=Primary)"
echo "  Action: Block ALL network connectivity for 5 minutes"
echo ""
echo "Secondary Network Disruption Template ID: ${SECONDARY_NET_ID}"
echo "  Targets: Secondary instances (FISTarget=True AND FISDBRole=Secondary)"
echo "  Action: Block ALL network connectivity for 5 minutes"
echo ""
echo "WARNING: This will block ALL network connectivity including:"
echo "  - SSM connectivity (you'll lose console access)"
echo "  - Database connections"
echo "  - Management traffic"
echo ""
echo "The instance will be isolated for 5 minutes, then connectivity will restore automatically."
echo ""
echo "To run an experiment:"
echo "  aws fis start-experiment --experiment-template-id ${PRIMARY_NET_ID}"
echo ""
