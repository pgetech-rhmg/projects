#!/bin/bash

# Deploy FIS experiment templates
# Creates the experiment templates in your AWS account

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "FIS Experiment Template Deployment"
echo "=========================================="
echo ""

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

if [ -z "$REGION" ]; then
    REGION="us-west-2"
    echo -e "${YELLOW}No default region configured, using: ${REGION}${NC}"
fi

echo "AWS Account ID: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo ""

# Check if FIS IAM role exists
echo "Checking for FIS IAM role..."
FIS_ROLE_NAME="FISExperimentRole"
FIS_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${FIS_ROLE_NAME}"

if aws iam get-role --role-name "${FIS_ROLE_NAME}" &>/dev/null; then
    echo -e "${GREEN}✓ FIS IAM role exists: ${FIS_ROLE_ARN}${NC}"
else
    echo -e "${RED}✗ FIS IAM role does not exist: ${FIS_ROLE_NAME}${NC}"
    echo ""
    echo "You need to create the FIS IAM role first."
    echo "Would you like me to create it now? (yes/no)"
    read -p "> " create_role

    if [ "$create_role" = "yes" ]; then
        echo "Creating FIS IAM role..."

        # Create trust policy
        cat > /tmp/fis-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "fis.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF

        # Create the role
        aws iam create-role \
          --role-name "${FIS_ROLE_NAME}" \
          --assume-role-policy-document file:///tmp/fis-trust-policy.json \
          --description "Role for AWS FIS experiments on OIH workload"

        # Create and attach policy
        cat > /tmp/fis-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/FISTarget": "True"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF

        aws iam put-role-policy \
          --role-name "${FIS_ROLE_NAME}" \
          --policy-name "FISExperimentPolicy" \
          --policy-document file:///tmp/fis-policy.json

        echo -e "${GREEN}✓ FIS IAM role created successfully${NC}"
        rm /tmp/fis-trust-policy.json /tmp/fis-policy.json
    else
        echo "Exiting. Please create the FIS IAM role manually."
        exit 1
    fi
fi

echo ""

# Check/Create CloudWatch log group
LOG_GROUP="/aws/fis/experiments"
LOG_GROUP_ARN="arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:${LOG_GROUP}"

echo "Checking for CloudWatch log group..."
if aws logs describe-log-groups --log-group-name-prefix "${LOG_GROUP}" --query "logGroups[?logGroupName=='${LOG_GROUP}'].logGroupName" --output text | grep -q "${LOG_GROUP}"; then
    echo -e "${GREEN}✓ CloudWatch log group exists: ${LOG_GROUP}${NC}"
else
    echo "Creating CloudWatch log group: ${LOG_GROUP}"
    aws logs create-log-group --log-group-name "${LOG_GROUP}"
    echo -e "${GREEN}✓ CloudWatch log group created${NC}"
fi

echo ""
echo "=========================================="
echo "Creating FIS Experiment Templates"
echo "=========================================="
echo ""

# Deploy Primary template
echo "1) Creating Primary DB Failover experiment template..."

PRIMARY_TEMPLATE_ID=$(aws fis create-experiment-template \
  --cli-input-yaml file://fis-templates/stop-primary-db-by-az.yaml \
  --role-arn "${FIS_ROLE_ARN}" \
  --log-configuration "cloudWatchLogsConfiguration={logGroupArn=${LOG_GROUP_ARN}},logSchemaVersion=2" \
  --query 'experimentTemplate.id' \
  --output text 2>&1)

if [[ $PRIMARY_TEMPLATE_ID == EXT* ]]; then
    echo -e "${GREEN}✓ Primary template created: ${PRIMARY_TEMPLATE_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create Primary template${NC}"
    echo "${PRIMARY_TEMPLATE_ID}"
fi

echo ""

# Deploy Secondary template
echo "2) Creating Secondary DB Isolation experiment template..."

SECONDARY_TEMPLATE_ID=$(aws fis create-experiment-template \
  --cli-input-yaml file://fis-templates/stop-secondary-db-by-az.yaml \
  --role-arn "${FIS_ROLE_ARN}" \
  --log-configuration "cloudWatchLogsConfiguration={logGroupArn=${LOG_GROUP_ARN}},logSchemaVersion=2" \
  --query 'experimentTemplate.id' \
  --output text 2>&1)

if [[ $SECONDARY_TEMPLATE_ID == EXT* ]]; then
    echo -e "${GREEN}✓ Secondary template created: ${SECONDARY_TEMPLATE_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create Secondary template${NC}"
    echo "${SECONDARY_TEMPLATE_ID}"
fi

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""

if [[ $PRIMARY_TEMPLATE_ID == EXT* ]]; then
    echo "Primary Failover Template ID: ${PRIMARY_TEMPLATE_ID}"
    echo "  Target: Primary instances in specified AZ"
    echo ""
fi

if [[ $SECONDARY_TEMPLATE_ID == EXT* ]]; then
    echo "Secondary Isolation Template ID: ${SECONDARY_TEMPLATE_ID}"
    echo "  Target: Secondary instances in specified AZ"
    echo ""
fi

echo "To run an experiment:"
echo "  ./scripts/run-fis-experiment.sh"
echo ""
echo "Or use AWS CLI directly:"
echo "  aws fis start-experiment \\"
echo "    --experiment-template-id ${PRIMARY_TEMPLATE_ID} \\"
echo "    --parameters targetAvailabilityZone=us-west-2b"
