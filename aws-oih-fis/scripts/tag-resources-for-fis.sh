#!/bin/bash

# Tag EC2 instances and EBS volumes for FIS experiment targeting
# This script helps safely tag your test resources with required FIS tags

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "FIS Resource Tagging Helper"
echo "=========================================="
echo ""

# Function to tag an EC2 instance
tag_instance() {
    local instance_id=$1
    local role=$2

    echo -e "${YELLOW}Tagging instance: ${instance_id} as ${role}${NC}"

    # Get instance details first
    instance_info=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].[InstanceId,State.Name,Placement.AvailabilityZone,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' --output text)

    echo "Instance Details:"
    echo "  ID: $(echo $instance_info | awk '{print $1}')"
    echo "  State: $(echo $instance_info | awk '{print $2}')"
    echo "  AZ: $(echo $instance_info | awk '{print $3}')"
    echo "  Private IP: $(echo $instance_info | awk '{print $4}')"
    echo "  Name: $(echo $instance_info | awk '{print $5}')"
    echo ""

    # Confirm before tagging
    read -p "Tag this instance as FISTarget=True, FISDBRole=${role}? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        aws ec2 create-tags \
            --resources "$instance_id" \
            --tags "Key=FISTarget,Value=True" "Key=FISDBRole,Value=${role}"

        echo -e "${GREEN}✓ Instance tagged successfully!${NC}"
    else
        echo -e "${RED}Tagging cancelled${NC}"
    fi
    echo ""
}

# Function to tag EBS volumes attached to an instance
tag_volumes_for_instance() {
    local instance_id=$1

    echo -e "${YELLOW}Finding EBS volumes attached to instance: ${instance_id}${NC}"
    echo ""

    # Get the FISDBRole tag from the instance
    instance_role=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --query 'Reservations[0].Instances[0].Tags[?Key==`FISDBRole`].Value|[0]' \
        --output text)

    if [ -z "$instance_role" ] || [ "$instance_role" = "None" ]; then
        echo -e "${RED}Instance ${instance_id} does not have FISDBRole tag set!${NC}"
        echo -e "${YELLOW}Please tag the instance first (options 1 or 2 in the menu)${NC}"
        echo ""
        return
    fi

    echo -e "Instance Role: ${GREEN}${instance_role}${NC}"
    echo ""

    # Get all volumes attached to the instance
    volumes=$(aws ec2 describe-volumes \
        --filters "Name=attachment.instance-id,Values=${instance_id}" \
        --query 'Volumes[].[VolumeId,Size,Attachments[0].Device,Tags[?Key==`Name`].Value|[0],VolumeType]' \
        --output text)

    if [ -z "$volumes" ]; then
        echo -e "${RED}No volumes found attached to instance ${instance_id}${NC}"
        echo ""
        return
    fi

    echo "Attached EBS Volumes:"
    echo "$volumes" | while IFS=$'\t' read -r vol_id size device name vol_type; do
        echo "  Volume ID: $vol_id"
        echo "    Size: ${size}GB"
        echo "    Device: $device"
        echo "    Name: $name"
        echo "    Type: $vol_type"
        echo ""
    done

    read -p "Tag ALL these volumes with FISTarget=True, FISEBSTarget=True, FISDBRole=${instance_role}? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        volume_ids=$(echo "$volumes" | awk '{print $1}')

        for vol_id in $volume_ids; do
            aws ec2 create-tags \
                --resources "$vol_id" \
                --tags "Key=FISTarget,Value=True" "Key=FISEBSTarget,Value=True" "Key=FISDBRole,Value=${instance_role}"
            echo -e "${GREEN}✓ Tagged volume: ${vol_id}${NC}"
        done

        echo -e "${GREEN}✓ All volumes tagged successfully!${NC}"
    else
        echo -e "${RED}Tagging cancelled${NC}"
    fi
    echo ""
}

# Function to tag a single EBS volume
tag_single_volume() {
    local volume_id=$1

    echo -e "${YELLOW}Tagging volume: ${volume_id}${NC}"

    # Get volume details
    volume_info=$(aws ec2 describe-volumes \
        --volume-ids "$volume_id" \
        --query 'Volumes[0].[VolumeId,Size,Attachments[0].Device,Attachments[0].InstanceId,State,Tags[?Key==`Name`].Value|[0],VolumeType]' \
        --output text)

    instance_id=$(echo $volume_info | awk '{print $4}')

    echo "Volume Details:"
    echo "  ID: $(echo $volume_info | awk '{print $1}')"
    echo "  Size: $(echo $volume_info | awk '{print $2}')GB"
    echo "  Device: $(echo $volume_info | awk '{print $3}')"
    echo "  Attached to: $instance_id"
    echo "  State: $(echo $volume_info | awk '{print $5}')"
    echo "  Name: $(echo $volume_info | awk '{print $6}')"
    echo "  Type: $(echo $volume_info | awk '{print $7}')"
    echo ""

    # Get the FISDBRole from the attached instance
    if [ "$instance_id" != "None" ] && [ -n "$instance_id" ]; then
        instance_role=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].Tags[?Key==`FISDBRole`].Value|[0]' \
            --output text)

        if [ -z "$instance_role" ] || [ "$instance_role" = "None" ]; then
            echo -e "${RED}Warning: Attached instance does not have FISDBRole tag!${NC}"
            echo -e "${YELLOW}Please tag the instance first, or manually specify role${NC}"
            read -p "Enter FISDBRole value (Primary/Secondary) or leave blank to skip: " manual_role
            instance_role=$manual_role
        else
            echo -e "Instance Role: ${GREEN}${instance_role}${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}Volume is not attached. Please specify FISDBRole:${NC}"
        read -p "Enter FISDBRole value (Primary/Secondary): " manual_role
        instance_role=$manual_role
    fi

    if [ -z "$instance_role" ]; then
        echo -e "${RED}Cannot tag without FISDBRole. Tagging cancelled.${NC}"
        echo ""
        return
    fi

    read -p "Tag this volume with FISTarget=True, FISEBSTarget=True, FISDBRole=${instance_role}? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        aws ec2 create-tags \
            --resources "$volume_id" \
            --tags "Key=FISTarget,Value=True" "Key=FISEBSTarget,Value=True" "Key=FISDBRole,Value=${instance_role}"

        echo -e "${GREEN}✓ Volume tagged successfully!${NC}"
    else
        echo -e "${RED}Tagging cancelled${NC}"
    fi
    echo ""
}

# Function to show instances that would be targeted by FIS
show_targeted_instances() {
    local role=$1

    echo -e "${YELLOW}Instances that would be targeted by FIS (FISTarget=True, FISDBRole=${role}):${NC}"

    aws ec2 describe-instances \
        --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISDBRole,Values=${role}" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].[InstanceId,State.Name,Placement.AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
        --output table

    echo ""
}

# Function to show EBS volumes that would be targeted by FIS
show_targeted_volumes() {
    echo -e "${YELLOW}EBS Volumes that would be targeted by FIS (FISTarget=True, FISEBSTarget=True):${NC}"
    echo ""

    aws ec2 describe-volumes \
        --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISEBSTarget,Values=True" \
        --query 'Volumes[].[VolumeId,Size,Attachments[0].Device,Attachments[0].InstanceId,State,Tags[?Key==`FISDBRole`].Value|[0],Tags[?Key==`Name`].Value|[0]]' \
        --output table

    echo ""
}

# Function to remove FIS tags from an instance
untag_instance() {
    local instance_id=$1

    echo -e "${YELLOW}Removing FIS tags from instance: ${instance_id}${NC}"

    aws ec2 delete-tags \
        --resources "$instance_id" \
        --tags "Key=FISTarget" "Key=FISDBRole"

    echo -e "${GREEN}✓ FIS tags removed from instance${NC}"
    echo ""
}

# Function to remove FIS tags from EBS volumes
untag_volumes_for_instance() {
    local instance_id=$1

    echo -e "${YELLOW}Finding and removing FIS tags from volumes attached to: ${instance_id}${NC}"

    volume_ids=$(aws ec2 describe-volumes \
        --filters "Name=attachment.instance-id,Values=${instance_id}" "Name=tag:FISTarget,Values=True" \
        --query 'Volumes[].VolumeId' \
        --output text)

    if [ -z "$volume_ids" ]; then
        echo -e "${YELLOW}No FIS-tagged volumes found attached to this instance${NC}"
        echo ""
        return
    fi

    for vol_id in $volume_ids; do
        aws ec2 delete-tags \
            --resources "$vol_id" \
            --tags "Key=FISTarget" "Key=FISEBSTarget" "Key=FISDBRole"
        echo -e "${GREEN}✓ Removed FIS tags from volume: ${vol_id}${NC}"
    done

    echo -e "${GREEN}✓ All volume tags removed${NC}"
    echo ""
}

# Main menu
while true; do
    echo "=========================================="
    echo "What would you like to do?"
    echo "=========================================="
    echo -e "${BLUE}EC2 Instances:${NC}"
    echo "  1) Tag an instance as Primary"
    echo "  2) Tag an instance as Secondary"
    echo "  3) Show all instances tagged as Primary"
    echo "  4) Show all instances tagged as Secondary"
    echo "  5) Remove FIS tags from an instance"
    echo ""
    echo -e "${BLUE}EBS Volumes:${NC}"
    echo "  6) Tag all volumes attached to an instance"
    echo "  7) Tag a single volume"
    echo "  8) Show all FIS-tagged volumes"
    echo "  9) Remove FIS tags from volumes attached to an instance"
    echo ""
    echo " 10) Exit"
    echo ""
    read -p "Choose an option (1-10): " choice
    echo ""

    case $choice in
        1)
            read -p "Enter instance ID to tag as Primary: " instance_id
            tag_instance "$instance_id" "Primary"
            ;;
        2)
            read -p "Enter instance ID to tag as Secondary: " instance_id
            tag_instance "$instance_id" "Secondary"
            ;;
        3)
            show_targeted_instances "Primary"
            ;;
        4)
            show_targeted_instances "Secondary"
            ;;
        5)
            read -p "Enter instance ID to remove FIS tags from: " instance_id
            untag_instance "$instance_id"
            ;;
        6)
            read -p "Enter instance ID to tag all attached volumes: " instance_id
            tag_volumes_for_instance "$instance_id"
            ;;
        7)
            read -p "Enter volume ID to tag: " volume_id
            tag_single_volume "$volume_id"
            ;;
        8)
            show_targeted_volumes
            ;;
        9)
            read -p "Enter instance ID to remove volume FIS tags: " instance_id
            untag_volumes_for_instance "$instance_id"
            ;;
        10)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            echo ""
            ;;
    esac
done
