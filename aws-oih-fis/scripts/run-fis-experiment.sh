#!/bin/bash

# Run FIS experiment with runtime parameters
# Safely executes FIS experiments with AZ specified at runtime

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "FIS Experiment Launcher"
echo "=========================================="
echo ""

# Function to show what would be targeted
preview_targets() {
    local role=$1
    local az=$2

    echo -e "${YELLOW}Instances that would be targeted:${NC}"
    echo "  Role Tag: FISDBRole=${role}"
    echo "  Safety Tag: FISTarget=True"
    echo "  Availability Zone: ${az}"
    echo ""

    instances=$(aws ec2 describe-instances \
        --filters \
            "Name=tag:FISTarget,Values=True" \
            "Name=tag:FISDBRole,Values=${role}" \
            "Name=instance-state-name,Values=running" \
            "Name=availability-zone,Values=${az}" \
        --query 'Reservations[].Instances[].[InstanceId,Placement.AvailabilityZone,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output text)

    if [ -z "$instances" ]; then
        echo -e "${GREEN}✓ No instances match these criteria${NC}"
        return 1
    else
        echo -e "${RED}⚠ WARNING: The following instances WILL BE STOPPED:${NC}"
        echo "$instances" | while IFS=$'\t' read -r id az ip name; do
            echo -e "  ${RED}►${NC} Instance: ${id}"
            echo "    Name: ${name}"
            echo "    AZ: ${az}"
            echo "    IP: ${ip}"
            echo ""
        done
        return 0
    fi
}

# Main menu
echo "Which experiment template do you want to run?"
echo ""
echo "1) Stop Primary DB instances in target AZ (tests failover)"
echo "2) Stop Secondary DB instances in target AZ (tests primary stability)"
echo "3) Exit"
echo ""
read -p "Choose experiment (1-3): " exp_choice
echo ""

case $exp_choice in
    1)
        TEMPLATE_ID_VAR="PRIMARY_TEMPLATE_ID"
        ROLE="Primary"
        SCENARIO="Primary Failover Test"
        ;;
    2)
        TEMPLATE_ID_VAR="SECONDARY_TEMPLATE_ID"
        ROLE="Secondary"
        SCENARIO="Secondary Isolation Test"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}Scenario: ${SCENARIO}${NC}"
echo ""

# Get target AZ
read -p "Enter target Availability Zone (e.g., us-west-2a, us-west-2b): " TARGET_AZ

if [ -z "$TARGET_AZ" ]; then
    echo -e "${RED}Error: AZ cannot be empty${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "SAFETY CHECK"
echo "=========================================="
echo ""

# Preview targets
if preview_targets "$ROLE" "$TARGET_AZ"; then
    echo ""
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}  THIS WILL STOP THE INSTANCES ABOVE  ${NC}"
    echo -e "${RED}  FOR 5 MINUTES                        ${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo ""
    read -p "Type 'YES' to proceed, anything else to cancel: " confirm

    if [ "$confirm" != "YES" ]; then
        echo -e "${GREEN}Experiment cancelled${NC}"
        exit 0
    fi
else
    echo ""
    echo -e "${GREEN}No instances would be affected. Experiment cancelled.${NC}"
    exit 0
fi

# Get experiment template ID
echo ""
read -p "Enter your FIS Experiment Template ID (EXT...): " TEMPLATE_ID

if [ -z "$TEMPLATE_ID" ]; then
    echo -e "${RED}Error: Template ID cannot be empty${NC}"
    exit 1
fi

echo ""
echo "Starting experiment..."
echo "  Template: ${TEMPLATE_ID}"
echo "  Target AZ: ${TARGET_AZ}"
echo ""

# Start the experiment
EXPERIMENT_ID=$(aws fis start-experiment \
    --experiment-template-id "$TEMPLATE_ID" \
    --experiment-options actionsMode=run-all \
    --parameters targetAvailabilityZone="$TARGET_AZ" \
    --query 'experiment.id' \
    --output text)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Experiment started successfully!${NC}"
    echo ""
    echo "Experiment ID: ${EXPERIMENT_ID}"
    echo ""
    echo "Monitor the experiment:"
    echo "  aws fis get-experiment --id ${EXPERIMENT_ID}"
    echo ""
    echo "Or view in console:"
    echo "  https://console.aws.amazon.com/fis/home#ExperimentDetails:id=${EXPERIMENT_ID}"
    echo ""
    echo "The experiment will:"
    echo "  - Stop targeted instances immediately"
    echo "  - Keep them stopped for 5 minutes"
    echo "  - Automatically start them after 5 minutes"
else
    echo -e "${RED}✗ Failed to start experiment${NC}"
    exit 1
fi
