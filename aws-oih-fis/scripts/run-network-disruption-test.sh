#!/bin/bash

# Orchestrate FIS Network Disruption Test
# Handles the full workflow: pre-test validation, experiment execution, post-test validation

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
STACK_NAME="fis-test-harness"
VPC_LAMBDA_NAME="FIS-Test-VPC-Lambda"
REGIONAL_LAMBDA_NAME="FIS-Test-Regional-Lambda"

echo -e "${BLUE}=============================================="
echo "FIS Network Disruption Test Orchestrator"
echo -e "==============================================${NC}"
echo ""

# Function to print section headers
print_header() {
    echo ""
    echo -e "${CYAN}======================================"
    echo "$1"
    echo -e "======================================${NC}"
    echo ""
}

# Function to test Lambda with timeout
test_lambda() {
    local function_name=$1
    local description=$2
    local timeout=10

    echo -n "Testing ${description}... "

    if timeout ${timeout} aws lambda invoke \
        --function-name "${function_name}" \
        /tmp/test-${function_name}.json \
        --query 'StatusCode' \
        --output text >/dev/null 2>&1; then
        echo -e "${GREEN}SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Function to check stack exists
check_stack_exists() {
    if ! aws cloudformation describe-stacks --stack-name "${STACK_NAME}" >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Stack '${STACK_NAME}' not found!${NC}"
        echo ""
        echo "Please deploy the test harness first:"
        echo "  aws cloudformation create-stack \\"
        echo "    --stack-name ${STACK_NAME} \\"
        echo "    --template-body file://cfn/FIS_test_harness.yaml \\"
        echo "    --parameters ParameterKey=VpcId,ParameterValue=<vpc-id> \\"
        echo "                 ParameterKey=TestSubnetId,ParameterValue=<subnet-id> \\"
        echo "    --capabilities CAPABILITY_NAMED_IAM"
        echo ""
        exit 1
    fi
}

# Function to get experiment template ID
get_template_id() {
    local template_id
    template_id=$(aws fis list-experiment-templates \
        --query 'experimentTemplates[?tags.Name==`OIH-Test-Subnet-Network-Disruption`].id' \
        --output text)

    if [ -z "${template_id}" ]; then
        echo -e "${RED}ERROR: FIS experiment template not found!${NC}"
        echo ""
        echo "Please create the template first:"
        echo "  aws fis create-experiment-template \\"
        echo "    --cli-input-yaml file://fis-templates/test-subnet-disruption.yaml"
        echo ""
        exit 1
    fi

    echo "${template_id}"
}

# Function to wait for experiment completion
wait_for_experiment() {
    local experiment_id=$1
    local duration=300 # 5 minutes
    local elapsed=0
    local interval=10

    echo "Waiting for experiment to complete (${duration}s duration)..."
    echo ""

    while [ ${elapsed} -lt ${duration} ]; do
        local status=$(aws fis get-experiment \
            --id "${experiment_id}" \
            --query 'experiment.state.status' \
            --output text 2>/dev/null || echo "ERROR")

        local remaining=$((duration - elapsed))
        echo -ne "\r[${elapsed}s elapsed / ${remaining}s remaining] Status: ${status}    "

        if [ "${status}" = "completed" ] || [ "${status}" = "failed" ] || [ "${status}" = "stopped" ]; then
            echo ""
            return 0
        fi

        sleep ${interval}
        elapsed=$((elapsed + interval))
    done

    echo ""
}

# ============================================
# MAIN TEST WORKFLOW
# ============================================

# Step 1: Verify prerequisites
print_header "Step 1: Verifying Prerequisites"

check_stack_exists
echo -e "${GREEN}✓ Test harness stack found${NC}"

TEMPLATE_ID=$(get_template_id)
echo -e "${GREEN}✓ FIS experiment template found: ${TEMPLATE_ID}${NC}"

# Get Lambda function names from stack
VPC_LAMBDA_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs[?OutputKey==`VPCLambdaFunctionName`].OutputValue' \
    --output text)

REGIONAL_LAMBDA_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs[?OutputKey==`RegionalLambdaFunctionName`].OutputValue' \
    --output text)

echo -e "${GREEN}✓ Lambda functions identified${NC}"
echo "  - VPC Lambda: ${VPC_LAMBDA_NAME}"
echo "  - Regional Lambda: ${REGIONAL_LAMBDA_NAME}"

# Step 2: Pre-flight validation
print_header "Step 2: Pre-Flight Validation (Baseline Connectivity)"

VPC_LAMBDA_BASELINE=0
REGIONAL_LAMBDA_BASELINE=0

test_lambda "${VPC_LAMBDA_NAME}" "VPC Lambda (will be isolated)" && VPC_LAMBDA_BASELINE=1
test_lambda "${REGIONAL_LAMBDA_NAME}" "Regional Lambda (control)" && REGIONAL_LAMBDA_BASELINE=1

if [ ${VPC_LAMBDA_BASELINE} -eq 0 ] || [ ${REGIONAL_LAMBDA_BASELINE} -eq 0 ]; then
    echo ""
    echo -e "${RED}ERROR: Baseline connectivity check failed!${NC}"
    echo "Both Lambda functions should work before starting the test."
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Baseline connectivity confirmed - all functions working${NC}"

# Step 3: Confirm execution
print_header "Step 3: Confirm Test Execution"

echo -e "${YELLOW}WARNING: This will disrupt network connectivity to the test subnet for 5 minutes.${NC}"
echo ""
echo "During the test:"
echo "  - VPC Lambda will become UNREACHABLE (timeout errors expected)"
echo "  - Regional Lambda will continue working (control)"
echo "  - EC2 instance will lose SSM connectivity"
echo ""
echo "After 5 minutes, connectivity will automatically restore."
echo ""

read -p "Do you want to proceed with the disruption test? (yes/no): " confirm

if [ "${confirm}" != "yes" ]; then
    echo ""
    echo "Test cancelled."
    exit 0
fi

# Step 4: Start FIS experiment
print_header "Step 4: Starting FIS Network Disruption Experiment"

EXPERIMENT_ID=$(aws fis start-experiment \
    --experiment-template-id "${TEMPLATE_ID}" \
    --tags "Name=Network-Disruption-Test-$(date +%Y%m%d-%H%M%S)" \
    --query 'experiment.id' \
    --output text)

echo -e "${GREEN}✓ Experiment started: ${EXPERIMENT_ID}${NC}"
echo ""
echo "CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:log-groups/log-group/\$252Faws\$252Ffis\$252Fexperiments"
echo "FIS Console: https://console.aws.amazon.com/fis/home?region=us-west-2#Experiments/${EXPERIMENT_ID}"
echo ""

# Wait a few seconds for FIS to apply disruption
echo "Waiting 15 seconds for disruption to take effect..."
sleep 15

# Step 5: During-test validation
print_header "Step 5: During-Test Validation (Connectivity Disrupted)"

echo "Testing Lambda functions during network disruption..."
echo ""

VPC_LAMBDA_DISRUPTED=0
REGIONAL_LAMBDA_DISRUPTED=0

# VPC Lambda should FAIL during disruption
if ! test_lambda "${VPC_LAMBDA_NAME}" "VPC Lambda (should be isolated)"; then
    VPC_LAMBDA_DISRUPTED=1
    echo -e "  ${GREEN}✓ Isolation confirmed: VPC Lambda is unreachable${NC}"
else
    echo -e "  ${RED}✗ Unexpected: VPC Lambda is still reachable (isolation may not be working)${NC}"
fi

# Regional Lambda should STILL WORK
if test_lambda "${REGIONAL_LAMBDA_NAME}" "Regional Lambda (should still work)"; then
    REGIONAL_LAMBDA_DISRUPTED=1
    echo -e "  ${GREEN}✓ Control confirmed: Regional Lambda still accessible${NC}"
else
    echo -e "  ${RED}✗ Unexpected: Regional Lambda is unreachable (should be unaffected)${NC}"
fi

echo ""
if [ ${VPC_LAMBDA_DISRUPTED} -eq 1 ] && [ ${REGIONAL_LAMBDA_DISRUPTED} -eq 1 ]; then
    echo -e "${GREEN}✓ Network disruption is working correctly!${NC}"
    echo "  - Subnet-level isolation: CONFIRMED"
    echo "  - Regional services unaffected: CONFIRMED"
else
    echo -e "${YELLOW}⚠ Unexpected behavior detected during disruption${NC}"
    echo "  This may indicate a configuration issue."
fi

# Step 6: Wait for experiment completion
print_header "Step 6: Waiting for Automatic Recovery"

wait_for_experiment "${EXPERIMENT_ID}"

EXPERIMENT_STATUS=$(aws fis get-experiment \
    --id "${EXPERIMENT_ID}" \
    --query 'experiment.state.status' \
    --output text)

echo ""
echo "Experiment status: ${EXPERIMENT_STATUS}"

# Wait a few seconds for connectivity to fully restore
echo ""
echo "Waiting 10 seconds for connectivity to fully restore..."
sleep 10

# Step 7: Post-test validation
print_header "Step 7: Post-Test Validation (Recovery Verification)"

echo "Testing Lambda functions after automatic recovery..."
echo ""

VPC_LAMBDA_RECOVERED=0
REGIONAL_LAMBDA_RECOVERED=0

test_lambda "${VPC_LAMBDA_NAME}" "VPC Lambda (should be recovered)" && VPC_LAMBDA_RECOVERED=1
test_lambda "${REGIONAL_LAMBDA_NAME}" "Regional Lambda (should still work)" && REGIONAL_LAMBDA_RECOVERED=1

echo ""
if [ ${VPC_LAMBDA_RECOVERED} -eq 1 ] && [ ${REGIONAL_LAMBDA_RECOVERED} -eq 1 ]; then
    echo -e "${GREEN}✓ Automatic recovery confirmed - all functions working${NC}"
else
    echo -e "${RED}✗ Recovery issue detected - some functions still unreachable${NC}"
    echo "  This may indicate a problem with automatic restoration."
fi

# Step 8: Test summary
print_header "Step 8: Test Summary"

echo "Test Results:"
echo ""
echo "Pre-Test (Baseline):"
echo "  VPC Lambda:      $([ ${VPC_LAMBDA_BASELINE} -eq 1 ] && echo -e "${GREEN}✓ Working${NC}" || echo -e "${RED}✗ Failed${NC}")"
echo "  Regional Lambda: $([ ${REGIONAL_LAMBDA_BASELINE} -eq 1 ] && echo -e "${GREEN}✓ Working${NC}" || echo -e "${RED}✗ Failed${NC}")"
echo ""
echo "During Test (Disruption):"
echo "  VPC Lambda:      $([ ${VPC_LAMBDA_DISRUPTED} -eq 1 ] && echo -e "${GREEN}✓ Isolated (expected)${NC}" || echo -e "${RED}✗ Still reachable (unexpected)${NC}")"
echo "  Regional Lambda: $([ ${REGIONAL_LAMBDA_DISRUPTED} -eq 1 ] && echo -e "${GREEN}✓ Working (expected)${NC}" || echo -e "${RED}✗ Unreachable (unexpected)${NC}")"
echo ""
echo "Post-Test (Recovery):"
echo "  VPC Lambda:      $([ ${VPC_LAMBDA_RECOVERED} -eq 1 ] && echo -e "${GREEN}✓ Recovered${NC}" || echo -e "${RED}✗ Still unreachable${NC}")"
echo "  Regional Lambda: $([ ${REGIONAL_LAMBDA_RECOVERED} -eq 1 ] && echo -e "${GREEN}✓ Working${NC}" || echo -e "${RED}✗ Failed${NC}")"
echo ""

# Overall test result
if [ ${VPC_LAMBDA_DISRUPTED} -eq 1 ] && [ ${REGIONAL_LAMBDA_DISRUPTED} -eq 1 ] && [ ${VPC_LAMBDA_RECOVERED} -eq 1 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   TEST PASSED: Network Disruption Works   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Key Findings:"
    echo "  ✓ Network disruption successfully isolated VPC-attached resources"
    echo "  ✓ Regional services remained unaffected during disruption"
    echo "  ✓ Automatic recovery restored connectivity after 5 minutes"
    echo "  ✓ No manual intervention required"
    echo ""
    echo -e "${GREEN}You can now confidently run network disruption experiments${NC}"
    echo -e "${GREEN}against your OIH Primary and Secondary AZ subnets!${NC}"
    EXIT_CODE=0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║    TEST INCOMPLETE: Review Results Above  ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Some aspects of the test did not behave as expected."
    echo "Review the results above and check the troubleshooting guide:"
    echo "  docs/NETWORK_DISRUPTION_TEST_GUIDE.md"
    EXIT_CODE=1
fi

echo ""
echo "Experiment ID: ${EXPERIMENT_ID}"
echo "CloudWatch Logs: /aws/fis/experiments"
echo "S3 Logs: s3://oih-dev-fis-logs/experiments/test-subnet-disruption/"
echo ""

exit ${EXIT_CODE}
