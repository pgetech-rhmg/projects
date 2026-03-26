#!/bin/bash

# Tag Subnets for FIS Network Disruption Experiments
# This script helps safely tag your subnets with required FIS tags for AZ failure simulation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "=========================================="
echo "FIS Subnet Tagging Helper"
echo "Network Disruption / AZ Failure Testing"
echo "=========================================="
echo ""

# Function to tag a subnet
tag_subnet() {
    local subnet_id=$1
    local az_role=$2

    echo -e "${YELLOW}Tagging subnet: ${subnet_id} as ${az_role}${NC}"
    echo ""

    # Get subnet details
    subnet_info=$(aws ec2 describe-subnets \
        --subnet-ids "$subnet_id" \
        --query 'Subnets[0].[SubnetId,CidrBlock,AvailabilityZone,VpcId,Tags[?Key==`Name`].Value|[0],State]' \
        --output text 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$subnet_info" ]; then
        echo -e "${RED}Error: Subnet ${subnet_id} not found or no access${NC}"
        echo ""
        return
    fi

    local subnet_id_info=$(echo $subnet_info | awk '{print $1}')
    local cidr=$(echo $subnet_info | awk '{print $2}')
    local az=$(echo $subnet_info | awk '{print $3}')
    local vpc_id=$(echo $subnet_info | awk '{print $4}')
    local name=$(echo $subnet_info | awk '{print $5}')
    local state=$(echo $subnet_info | awk '{print $6}')

    # Get count of ENIs in this subnet
    eni_count=$(aws ec2 describe-network-interfaces \
        --filters "Name=subnet-id,Values=${subnet_id}" \
        --query 'length(NetworkInterfaces)' \
        --output text)

    # Get sample of resources in this subnet
    echo -e "${CYAN}Subnet Details:${NC}"
    echo "  Subnet ID:    $subnet_id_info"
    echo "  Name:         $name"
    echo "  CIDR:         $cidr"
    echo "  AZ:           $az"
    echo "  VPC:          $vpc_id"
    echo "  State:        $state"
    echo "  ENIs:         $eni_count network interfaces"
    echo ""

    # Show what's in this subnet (sample)
    if [ "$eni_count" -gt 0 ]; then
        echo -e "${CYAN}Resources in this subnet (sample):${NC}"

        # Check for EC2 instances
        instances=$(aws ec2 describe-instances \
            --filters "Name=subnet-id,Values=${subnet_id}" "Name=instance-state-name,Values=running,stopped" \
            --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
            --output text 2>/dev/null | head -5)

        if [ -n "$instances" ]; then
            echo -e "  ${YELLOW}EC2 Instances:${NC}"
            echo "$instances" | while IFS=$'\t' read -r inst_id state inst_name; do
                echo "    - $inst_id ($state) - $inst_name"
            done
        fi

        # Check for Lambda ENIs
        lambda_enis=$(aws ec2 describe-network-interfaces \
            --filters "Name=subnet-id,Values=${subnet_id}" "Name=interface-type,Values=lambda" \
            --query 'length(NetworkInterfaces)' \
            --output text)

        if [ "$lambda_enis" -gt 0 ]; then
            echo -e "  ${YELLOW}Lambda Functions:${NC} $lambda_enis ENIs (VPC-attached functions)"
        fi

        # Check for RDS instances
        rds_instances=$(aws rds describe-db-instances \
            --query "DBInstances[?DBSubnetGroup.Subnets[?SubnetIdentifier=='${subnet_id}']].DBInstanceIdentifier" \
            --output text 2>/dev/null)

        if [ -n "$rds_instances" ]; then
            echo -e "  ${YELLOW}RDS Instances:${NC}"
            echo "$rds_instances" | tr '\t' '\n' | while read -r db_id; do
                echo "    - $db_id"
            done
        fi

        # Check for load balancers
        lb_enis=$(aws ec2 describe-network-interfaces \
            --filters "Name=subnet-id,Values=${subnet_id}" "Name=interface-type,Values=network_load_balancer,gateway_load_balancer" \
            --query 'length(NetworkInterfaces)' \
            --output text)

        if [ "$lb_enis" -gt 0 ]; then
            echo -e "  ${YELLOW}Load Balancers:${NC} $lb_enis ENIs"
        fi

        echo ""
    fi

    # Check if subnet is already tagged
    existing_tags=$(aws ec2 describe-subnets \
        --subnet-ids "$subnet_id" \
        --query 'Subnets[0].Tags[?Key==`FISTarget` || Key==`FISAZRole`].[Key,Value]' \
        --output text 2>/dev/null)

    if [ -n "$existing_tags" ]; then
        echo -e "${YELLOW}⚠ This subnet is already tagged for FIS:${NC}"
        echo "$existing_tags" | while IFS=$'\t' read -r key value; do
            echo "    $key = $value"
        done
        echo ""
        read -p "Do you want to UPDATE these tags? (yes/no): " update_confirm
        if [ "$update_confirm" != "yes" ]; then
            echo -e "${RED}Tagging cancelled${NC}"
            echo ""
            return
        fi
        echo ""
    fi

    # Warning about impact
    echo -e "${RED}⚠ WARNING: Network Disruption Impact${NC}"
    echo "  When you run a network disruption experiment on this subnet:"
    echo "  - ALL resources in this subnet will be isolated for 5 minutes"
    echo "  - EC2 instances will lose connectivity (SSH/SSM/apps)"
    echo "  - Lambda functions will timeout on invocation"
    echo "  - RDS databases will be unreachable"
    echo "  - Load balancers will fail health checks"
    echo ""
    echo "  Recovery is automatic after 5 minutes."
    echo ""

    read -p "Tag this subnet with FISTarget=True, FISAZRole=${az_role}? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        aws ec2 create-tags \
            --resources "$subnet_id" \
            --tags "Key=FISTarget,Value=True" "Key=FISAZRole,Value=${az_role}"

        echo -e "${GREEN}✓ Subnet tagged successfully!${NC}"
        echo "  FISTarget: True"
        echo "  FISAZRole: ${az_role}"
    else
        echo -e "${RED}Tagging cancelled${NC}"
    fi
    echo ""
}

# Function to tag multiple subnets in same AZ
tag_subnets_by_az() {
    local az=$1
    local az_role=$2

    echo -e "${YELLOW}Finding all subnets in AZ: ${az}${NC}"
    echo ""

    # Get subnets in this AZ
    subnets=$(aws ec2 describe-subnets \
        --filters "Name=availability-zone,Values=${az}" \
        --query 'Subnets[].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0],State]' \
        --output text)

    if [ -z "$subnets" ]; then
        echo -e "${RED}No subnets found in AZ ${az}${NC}"
        echo ""
        return
    fi

    echo -e "${CYAN}Subnets in ${az}:${NC}"
    echo "$subnets" | while IFS=$'\t' read -r sub_id cidr name state; do
        echo "  - $sub_id ($cidr) - $name [$state]"
    done
    echo ""

    local subnet_count=$(echo "$subnets" | wc -l | tr -d ' ')
    echo "Found ${subnet_count} subnet(s)"
    echo ""

    read -p "Tag ALL these subnets with FISTarget=True, FISAZRole=${az_role}? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        subnet_ids=$(echo "$subnets" | awk '{print $1}')

        for sub_id in $subnet_ids; do
            aws ec2 create-tags \
                --resources "$sub_id" \
                --tags "Key=FISTarget,Value=True" "Key=FISAZRole,Value=${az_role}"
            echo -e "${GREEN}✓ Tagged subnet: ${sub_id}${NC}"
        done

        echo ""
        echo -e "${GREEN}✓ All ${subnet_count} subnet(s) tagged successfully!${NC}"
    else
        echo -e "${RED}Tagging cancelled${NC}"
    fi
    echo ""
}

# Function to show subnets that would be targeted by FIS
show_targeted_subnets() {
    local az_role=$1

    if [ -z "$az_role" ]; then
        echo -e "${YELLOW}All subnets tagged for FIS network disruption:${NC}"
        echo ""

        aws ec2 describe-subnets \
            --filters "Name=tag:FISTarget,Values=True" \
            --query 'Subnets[].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`FISAZRole`].Value|[0],Tags[?Key==`Name`].Value|[0]]' \
            --output table
    else
        echo -e "${YELLOW}Subnets that would be targeted by FIS (FISTarget=True, FISAZRole=${az_role}):${NC}"
        echo ""

        aws ec2 describe-subnets \
            --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISAZRole,Values=${az_role}" \
            --query 'Subnets[].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
            --output table
    fi

    echo ""
}

# Function to show detailed view of what would be affected
show_impact_summary() {
    local az_role=$1

    echo -e "${YELLOW}Impact Summary: What will be disrupted for FISAZRole=${az_role}${NC}"
    echo ""

    # Get targeted subnets
    subnet_ids=$(aws ec2 describe-subnets \
        --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISAZRole,Values=${az_role}" \
        --query 'Subnets[].SubnetId' \
        --output text)

    if [ -z "$subnet_ids" ]; then
        echo -e "${RED}No subnets tagged with FISAZRole=${az_role}${NC}"
        echo ""
        return
    fi

    local subnet_count=$(echo "$subnet_ids" | wc -w)
    echo "Target: ${subnet_count} subnet(s)"
    echo ""

    # Count resources per subnet
    for subnet_id in $subnet_ids; do
        subnet_name=$(aws ec2 describe-subnets \
            --subnet-ids "$subnet_id" \
            --query 'Subnets[0].[Tags[?Key==`Name`].Value|[0],AvailabilityZone,CidrBlock]' \
            --output text)

        name=$(echo $subnet_name | awk '{print $1}')
        az=$(echo $subnet_name | awk '{print $2}')
        cidr=$(echo $subnet_name | awk '{print $3}')

        echo -e "${CYAN}Subnet: ${subnet_id} (${name})${NC}"
        echo "  AZ: $az | CIDR: $cidr"

        # Count EC2 instances
        ec2_count=$(aws ec2 describe-instances \
            --filters "Name=subnet-id,Values=${subnet_id}" "Name=instance-state-name,Values=running,stopped" \
            --query 'length(Reservations[].Instances[])' \
            --output text)

        if [ "$ec2_count" != "0" ]; then
            echo "  - EC2 Instances: ${ec2_count}"
        fi

        # Count Lambda ENIs
        lambda_count=$(aws ec2 describe-network-interfaces \
            --filters "Name=subnet-id,Values=${subnet_id}" "Name=interface-type,Values=lambda" \
            --query 'length(NetworkInterfaces)' \
            --output text)

        if [ "$lambda_count" != "0" ]; then
            echo "  - Lambda ENIs: ${lambda_count} (VPC-attached functions)"
        fi

        # Count total ENIs
        eni_count=$(aws ec2 describe-network-interfaces \
            --filters "Name=subnet-id,Values=${subnet_id}" \
            --query 'length(NetworkInterfaces)' \
            --output text)

        echo "  - Total ENIs: ${eni_count}"
        echo ""
    done

    echo -e "${RED}⚠ Running a network disruption experiment will isolate ALL these resources${NC}"
    echo ""
}

# Function to list available AZs with subnet counts
list_availability_zones() {
    echo -e "${YELLOW}Availability Zones with Subnets:${NC}"
    echo ""

    aws ec2 describe-subnets \
        --query 'Subnets[].[AvailabilityZone]' \
        --output text | sort | uniq -c | awk '{print "  " $2 " - " $1 " subnet(s)"}'

    echo ""
}

# Function to remove FIS tags from a subnet
untag_subnet() {
    local subnet_id=$1

    echo -e "${YELLOW}Removing FIS tags from subnet: ${subnet_id}${NC}"

    # Check if subnet has FIS tags
    existing_tags=$(aws ec2 describe-subnets \
        --subnet-ids "$subnet_id" \
        --query 'Subnets[0].Tags[?Key==`FISTarget` || Key==`FISAZRole`].[Key,Value]' \
        --output text 2>/dev/null)

    if [ -z "$existing_tags" ]; then
        echo -e "${YELLOW}Subnet ${subnet_id} has no FIS tags${NC}"
        echo ""
        return
    fi

    echo "Current FIS tags:"
    echo "$existing_tags" | while IFS=$'\t' read -r key value; do
        echo "  $key = $value"
    done
    echo ""

    read -p "Remove these FIS tags? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        aws ec2 delete-tags \
            --resources "$subnet_id" \
            --tags "Key=FISTarget" "Key=FISAZRole"

        echo -e "${GREEN}✓ FIS tags removed from subnet${NC}"
    else
        echo -e "${RED}Tag removal cancelled${NC}"
    fi
    echo ""
}

# Function to remove FIS tags from all subnets in an AZ
untag_subnets_by_az() {
    local az=$1

    echo -e "${YELLOW}Finding FIS-tagged subnets in AZ: ${az}${NC}"
    echo ""

    subnet_ids=$(aws ec2 describe-subnets \
        --filters "Name=availability-zone,Values=${az}" "Name=tag:FISTarget,Values=True" \
        --query 'Subnets[].SubnetId' \
        --output text)

    if [ -z "$subnet_ids" ]; then
        echo -e "${YELLOW}No FIS-tagged subnets found in AZ ${az}${NC}"
        echo ""
        return
    fi

    local subnet_count=$(echo "$subnet_ids" | wc -w)
    echo "Found ${subnet_count} FIS-tagged subnet(s) in ${az}"
    echo ""

    for subnet_id in $subnet_ids; do
        echo "  - $subnet_id"
    done
    echo ""

    read -p "Remove FIS tags from ALL these subnets? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        for sub_id in $subnet_ids; do
            aws ec2 delete-tags \
                --resources "$sub_id" \
                --tags "Key=FISTarget" "Key=FISAZRole"
            echo -e "${GREEN}✓ Removed FIS tags from: ${sub_id}${NC}"
        done

        echo ""
        echo -e "${GREEN}✓ All FIS tags removed from ${subnet_count} subnet(s)${NC}"
    else
        echo -e "${RED}Tag removal cancelled${NC}"
    fi
    echo ""
}

# Function to remove all FIS tags from all subnets
untag_all_subnets() {
    echo -e "${RED}⚠ WARNING: Remove ALL FIS tags from ALL subnets?${NC}"
    echo ""

    subnet_ids=$(aws ec2 describe-subnets \
        --filters "Name=tag:FISTarget,Values=True" \
        --query 'Subnets[].SubnetId' \
        --output text)

    if [ -z "$subnet_ids" ]; then
        echo -e "${YELLOW}No FIS-tagged subnets found${NC}"
        echo ""
        return
    fi

    local subnet_count=$(echo "$subnet_ids" | wc -w)
    echo "Found ${subnet_count} FIS-tagged subnet(s)"
    echo ""

    read -p "Remove FIS tags from ALL ${subnet_count} subnet(s)? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        for sub_id in $subnet_ids; do
            aws ec2 delete-tags \
                --resources "$sub_id" \
                --tags "Key=FISTarget" "Key=FISAZRole"
            echo -e "${GREEN}✓ Removed FIS tags from: ${sub_id}${NC}"
        done

        echo ""
        echo -e "${GREEN}✓ All FIS tags removed from ${subnet_count} subnet(s)${NC}"
    else
        echo -e "${RED}Tag removal cancelled${NC}"
    fi
    echo ""
}

# Main menu
while true; do
    echo "=========================================="
    echo "What would you like to do?"
    echo "=========================================="
    echo -e "${BLUE}Tag Subnets for Network Disruption:${NC}"
    echo "  1) Tag a single subnet (by Subnet ID)"
    echo "  2) Tag all subnets in an AZ as Primary"
    echo "  3) Tag all subnets in an AZ as Secondary"
    echo "  4) Tag all subnets in an AZ as TestAZ (for isolated testing)"
    echo ""
    echo -e "${BLUE}View Tagged Subnets:${NC}"
    echo "  5) Show all FIS-tagged subnets"
    echo "  6) Show Primary AZ subnets (FISAZRole=Primary)"
    echo "  7) Show Secondary AZ subnets (FISAZRole=Secondary)"
    echo "  8) Show TestAZ subnets (FISAZRole=TestAZ)"
    echo "  9) Show impact summary (what will be disrupted)"
    echo ""
    echo -e "${BLUE}Remove Tags:${NC}"
    echo " 10) Remove FIS tags from a single subnet"
    echo " 11) Remove FIS tags from all subnets in an AZ"
    echo " 12) Remove ALL FIS tags from ALL subnets (nuclear option)"
    echo ""
    echo -e "${BLUE}Utility:${NC}"
    echo " 13) List all Availability Zones with subnet counts"
    echo ""
    echo " 14) Exit"
    echo ""
    read -p "Choose an option (1-14): " choice
    echo ""

    case $choice in
        1)
            read -p "Enter subnet ID to tag: " subnet_id
            echo ""
            echo "Choose AZ role:"
            echo "  1) Primary"
            echo "  2) Secondary"
            echo "  3) TestAZ"
            read -p "Choose role (1-3): " role_choice
            echo ""

            case $role_choice in
                1) tag_subnet "$subnet_id" "Primary" ;;
                2) tag_subnet "$subnet_id" "Secondary" ;;
                3) tag_subnet "$subnet_id" "TestAZ" ;;
                *) echo -e "${RED}Invalid role choice${NC}"; echo "" ;;
            esac
            ;;
        2)
            read -p "Enter Availability Zone (e.g., us-west-2a): " az
            echo ""
            tag_subnets_by_az "$az" "Primary"
            ;;
        3)
            read -p "Enter Availability Zone (e.g., us-west-2b): " az
            echo ""
            tag_subnets_by_az "$az" "Secondary"
            ;;
        4)
            read -p "Enter Availability Zone (e.g., us-west-2d): " az
            echo ""
            tag_subnets_by_az "$az" "TestAZ"
            ;;
        5)
            show_targeted_subnets ""
            ;;
        6)
            show_targeted_subnets "Primary"
            ;;
        7)
            show_targeted_subnets "Secondary"
            ;;
        8)
            show_targeted_subnets "TestAZ"
            ;;
        9)
            echo "Choose AZ role to analyze:"
            echo "  1) Primary"
            echo "  2) Secondary"
            echo "  3) TestAZ"
            read -p "Choose role (1-3): " role_choice
            echo ""

            case $role_choice in
                1) show_impact_summary "Primary" ;;
                2) show_impact_summary "Secondary" ;;
                3) show_impact_summary "TestAZ" ;;
                *) echo -e "${RED}Invalid role choice${NC}"; echo "" ;;
            esac
            ;;
        10)
            read -p "Enter subnet ID to remove FIS tags from: " subnet_id
            echo ""
            untag_subnet "$subnet_id"
            ;;
        11)
            read -p "Enter Availability Zone (e.g., us-west-2d): " az
            echo ""
            untag_subnets_by_az "$az"
            ;;
        12)
            untag_all_subnets
            ;;
        13)
            list_availability_zones
            ;;
        14)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            echo ""
            ;;
    esac
done
