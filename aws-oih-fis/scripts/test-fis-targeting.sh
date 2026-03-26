#!/bin/bash

# Dry-run test to verify FIS experiment targeting
# Shows exactly which instances would be affected WITHOUT running the experiment

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "FIS Targeting Dry-Run Test"
echo "=========================================="
echo ""

# Test Primary targeting
echo -e "${YELLOW}TEST 1: Primary DB instances that would be stopped${NC}"
echo "Tags Required: FISTarget=True AND FISDBRole=Primary"
echo "AZ Filter: us-west-2b"
echo ""

primary_instances=$(aws ec2 describe-instances \
    --filters \
        "Name=tag:FISTarget,Values=True" \
        "Name=tag:FISDBRole,Values=Primary" \
        "Name=instance-state-name,Values=running" \
        "Name=availability-zone,Values=us-west-2b" \
    --query 'Reservations[].Instances[].[InstanceId,Placement.AvailabilityZone,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
    --output text)

if [ -z "$primary_instances" ]; then
    echo -e "${GREEN}✓ SAFE: No instances match Primary targeting criteria${NC}"
else
    echo -e "${RED}⚠ WARNING: The following instances WOULD BE STOPPED:${NC}"
    echo "$primary_instances" | while read line; do
        echo "  - $line"
    done
fi

echo ""
echo "=========================================="
echo ""

# Test Secondary targeting
echo -e "${YELLOW}TEST 2: Secondary DB instances that would be stopped${NC}"
echo "Tags Required: FISTarget=True AND FISDBRole=Secondary"
echo "AZ Filter: us-west-2a"
echo ""

secondary_instances=$(aws ec2 describe-instances \
    --filters \
        "Name=tag:FISTarget,Values=True" \
        "Name=tag:FISDBRole,Values=Secondary" \
        "Name=instance-state-name,Values=running" \
        "Name=availability-zone,Values=us-west-2a" \
    --query 'Reservations[].Instances[].[InstanceId,Placement.AvailabilityZone,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
    --output text)

if [ -z "$secondary_instances" ]; then
    echo -e "${GREEN}✓ SAFE: No instances match Secondary targeting criteria${NC}"
else
    echo -e "${RED}⚠ WARNING: The following instances WOULD BE STOPPED:${NC}"
    echo "$secondary_instances" | while read line; do
        echo "  - $line"
    done
fi

echo ""
echo "=========================================="
echo ""

# Show all instances with FISTarget tag
echo -e "${YELLOW}ALL instances with FISTarget=True tag:${NC}"
echo ""

all_fis_instances=$(aws ec2 describe-instances \
    --filters "Name=tag:FISTarget,Values=True" \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,Placement.AvailabilityZone,Tags[?Key==`FISDBRole`].Value|[0],Tags[?Key==`Name`].Value|[0]]' \
    --output table)

if [ -z "$all_fis_instances" ]; then
    echo -e "${GREEN}No instances are currently tagged with FISTarget=True${NC}"
else
    echo "$all_fis_instances"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Dry-run complete. No instances were modified.${NC}"
echo "=========================================="
