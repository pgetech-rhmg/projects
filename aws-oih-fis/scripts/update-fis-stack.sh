#!/bin/bash

# Update FIS CloudFormation stack with experiment templates
# This replaces the need for individual experiment creation scripts

set -e

STACK_NAME="${1:-fis-infrastructure}"
TEMPLATE_FILE="cfn/FIS_plumbing.yaml"

echo "=========================================="
echo "Updating FIS CloudFormation Stack"
echo "=========================================="
echo ""
echo "Stack Name: ${STACK_NAME}"
echo "Template: ${TEMPLATE_FILE}"
echo ""

# Check if stack exists
if aws cloudformation describe-stacks --stack-name "${STACK_NAME}" > /dev/null 2>&1; then
    echo "Stack exists. Updating..."
    echo ""

    aws cloudformation update-stack \
        --stack-name "${STACK_NAME}" \
        --template-body "file://${TEMPLATE_FILE}" \
        --capabilities CAPABILITY_NAMED_IAM

    echo ""
    echo "Waiting for stack update to complete..."
    aws cloudformation wait stack-update-complete --stack-name "${STACK_NAME}"

    echo ""
    echo "✓ Stack updated successfully!"
else
    echo "Stack does not exist. Creating..."
    echo ""

    aws cloudformation create-stack \
        --stack-name "${STACK_NAME}" \
        --template-body "file://${TEMPLATE_FILE}" \
        --capabilities CAPABILITY_NAMED_IAM

    echo ""
    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name "${STACK_NAME}"

    echo ""
    echo "✓ Stack created successfully!"
fi

echo ""
echo "=========================================="
echo "Stack Outputs"
echo "=========================================="
echo ""

aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo "=========================================="
echo "FIS Experiment Templates Created"
echo "=========================================="
echo ""
echo "The following experiment templates are now available:"
echo ""
echo "1. Primary EC2 Stop/Restart (5 minutes)"
echo "   - Targets: Instances with FISTarget=True, FISDBRole=Primary"
echo ""
echo "2. Secondary EC2 Stop/Restart (5 minutes)"
echo "   - Targets: Instances with FISTarget=True, FISDBRole=Secondary"
echo ""
echo "3. Primary EBS I/O Pause (5 minutes)"
echo "   - Targets: Volumes with FISTarget=True, FISEBSTarget=True, FISDBRole=Primary"
echo ""
echo "4. Secondary EBS I/O Pause (5 minutes)"
echo "   - Targets: Volumes with FISTarget=True, FISEBSTarget=True, FISDBRole=Secondary"
echo ""
echo "5. Primary Network Disruption (5 minutes)"
echo "   - Targets: Instances with FISTarget=True, FISDBRole=Primary"
echo ""
echo "6. Secondary Network Disruption (5 minutes)"
echo "   - Targets: Instances with FISTarget=True, FISDBRole=Secondary"
echo ""
echo "All templates log to:"
echo "  - CloudWatch: /aws/fis/experiments"
echo "  - S3: s3://oih-dev-fis-logs/experiments/"
echo ""
echo "To run an experiment, use the template ID from the stack outputs:"
echo "  aws fis start-experiment --experiment-template-id <TEMPLATE_ID>"
echo ""
