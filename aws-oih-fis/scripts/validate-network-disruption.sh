#!/bin/bash

# Validate FIS Network Disruption Test
# Tests connectivity to VPC-attached resources before, during, and after disruption

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VPC_LAMBDA_NAME="${1:-FIS-Test-VPC-Lambda}"
REGIONAL_LAMBDA_NAME="${2:-FIS-Test-Regional-Lambda}"
TEST_INTERVAL="${3:-10}" # seconds between tests

echo -e "${BLUE}=========================================="
echo "FIS Network Disruption Validation Test"
echo -e "==========================================${NC}"
echo ""
echo "This script will continuously test Lambda functions to validate network isolation."
echo ""
echo "Configuration:"
echo "  VPC Lambda (will be isolated):    ${VPC_LAMBDA_NAME}"
echo "  Regional Lambda (control):        ${REGIONAL_LAMBDA_NAME}"
echo "  Test interval:                    ${TEST_INTERVAL} seconds"
echo ""
echo -e "${YELLOW}Instructions:${NC}"
echo "  1. Run this script in a terminal window"
echo "  2. In another terminal, start the FIS experiment"
echo "  3. Observe the test results change from SUCCESS to FAILURE during disruption"
echo "  4. After 5 minutes, observe automatic recovery"
echo ""
echo "Press Ctrl+C to stop testing at any time."
echo ""
read -p "Press Enter to start continuous testing..."
echo ""

# Test counter
test_num=0

# Function to test VPC Lambda
test_vpc_lambda() {
    local output
    local result

    output=$(aws lambda invoke \
        --function-name "${VPC_LAMBDA_NAME}" \
        --log-type Tail \
        /tmp/fis-vpc-test.json 2>&1) || result=$?

    if [ -z "${result}" ]; then
        # Successful invocation
        local response=$(cat /tmp/fis-vpc-test.json)
        local dns=$(echo "${response}" | jq -r '.body | fromjson | .tests.dns_resolution // "UNKNOWN"')
        local connectivity=$(echo "${response}" | jq -r '.body | fromjson | .tests.external_connectivity // "UNKNOWN"')

        echo -e "${GREEN}✓ VPC Lambda${NC}: Invocation SUCCESS | DNS: ${dns} | External: ${connectivity}"
    else
        # Failed invocation
        local error=$(echo "${output}" | grep -i "error" | head -1)
        echo -e "${RED}✗ VPC Lambda${NC}: Invocation FAILED - ${error:-Timeout or network isolation}"
    fi
}

# Function to test Regional Lambda
test_regional_lambda() {
    local output
    local result

    output=$(aws lambda invoke \
        --function-name "${REGIONAL_LAMBDA_NAME}" \
        --log-type Tail \
        /tmp/fis-regional-test.json 2>&1) || result=$?

    if [ -z "${result}" ]; then
        echo -e "${GREEN}✓ Regional Lambda${NC}: Invocation SUCCESS (control - should always work)"
    else
        echo -e "${RED}✗ Regional Lambda${NC}: Invocation FAILED (unexpected - this is a control!)"
    fi
}

# Main test loop
while true; do
    test_num=$((test_num + 1))
    timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    echo -e "${BLUE}[Test #${test_num}]${NC} ${timestamp}"
    echo "------------------------------------------------------------"

    # Test VPC Lambda (should FAIL during disruption)
    test_vpc_lambda

    # Test Regional Lambda (should ALWAYS work)
    test_regional_lambda

    echo ""

    # Wait before next test
    sleep "${TEST_INTERVAL}"
done
