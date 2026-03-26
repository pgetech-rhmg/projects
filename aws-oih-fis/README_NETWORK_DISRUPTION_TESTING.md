# Network Disruption Testing - Quick Start

## Overview

You've created an isolated test subnet (100.64.0.0/24 in AZ-D) to safely validate FIS network disruption experiments before running them against production OIH resources.

## How Network Disruption Works

- **Action**: `aws:network:disrupt-connectivity`
- **Target**: Entire subnets (not individual resources)
- **Scope**: Blocks ALL ingress AND egress traffic
- **Mechanism**: Temporarily modifies subnet Network ACLs to DENY ALL
- **Duration**: 5 minutes (automatically restores after)

**What Gets Isolated:**
- EC2 instances (no SSH, SSM, app traffic)
- VPC-attached Lambda functions (timeout on invoke)
- API Gateway private endpoints (unreachable)
- RDS instances (connection timeouts)
- Everything with a network interface in the subnet

**What Does NOT Get Isolated:**
- Regional Lambda (no VPC attachment)
- CloudFront, S3, DynamoDB (direct access)
- Resources in other subnets

---

## Quick Start: Validate Network Disruption

### 1. Deploy Test Harness

```bash
# Set your parameters
export TEST_SUBNET_ID="subnet-xxxxxxxxx"  # Your AZ-D isolated subnet
export VPC_ID="vpc-xxxxxxxxx"             # Your VPC

# Deploy test resources (Lambda functions, EC2, security groups)
aws cloudformation create-stack \
  --stack-name fis-test-harness \
  --template-body file://cfn/FIS_test_harness.yaml \
  --parameters \
    ParameterKey=VpcId,ParameterValue=${VPC_ID} \
    ParameterKey=TestSubnetId,ParameterValue=${TEST_SUBNET_ID} \
    ParameterKey=TestSubnetCIDR,ParameterValue=100.64.0.0/24 \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for completion (~3 minutes)
aws cloudformation wait stack-create-complete --stack-name fis-test-harness
```

### 2. Tag Test Subnet for FIS Targeting

```bash
# Tag subnet so FIS can find it
aws ec2 create-tags \
  --resources ${TEST_SUBNET_ID} \
  --tags \
    Key=FISTarget,Value=True \
    Key=FISAZRole,Value=TestAZ
```

### 3. Create FIS Experiment Template

```bash
# Create experiment template
aws fis create-experiment-template \
  --cli-input-yaml file://fis-templates/test-subnet-disruption.yaml
```

### 4. Run the Test

```bash
# Automated test (recommended - handles everything)
./scripts/run-network-disruption-test.sh

# OR manual test (for step-by-step control)
# Terminal 1: Start monitoring
./scripts/validate-network-disruption.sh

# Terminal 2: Start experiment
TEMPLATE_ID=$(aws fis list-experiment-templates \
  --query 'experimentTemplates[?tags.Name==`OIH-Test-Subnet-Network-Disruption`].id' \
  --output text)

aws fis start-experiment --experiment-template-id ${TEMPLATE_ID}
```

---

## What to Expect

### ✅ Before Experiment (Baseline)
```
✓ VPC Lambda: Invocation SUCCESS | DNS: SUCCESS | External: SUCCESS
✓ Regional Lambda: Invocation SUCCESS (control)
```

### ⚠️ During Experiment (Disruption - 5 minutes)
```
✗ VPC Lambda: Invocation FAILED - Timeout or network isolation
✓ Regional Lambda: Invocation SUCCESS (unaffected)
```

### ✅ After Experiment (Automatic Recovery)
```
✓ VPC Lambda: Invocation SUCCESS | DNS: SUCCESS | External: SUCCESS
✓ Regional Lambda: Invocation SUCCESS (control)
```

**Key Validation:**
- VPC Lambda **fails during disruption** = Isolation working ✓
- Regional Lambda **keeps working** = Scope is subnet-specific ✓
- VPC Lambda **recovers automatically** = FIS restoration working ✓

---

## Files Created

### CloudFormation Templates
- `cfn/FIS_test_harness.yaml` - Test resources (Lambda, EC2, IAM roles)
- `fis-templates/test-subnet-disruption.yaml` - FIS experiment template

### Scripts
- `scripts/run-network-disruption-test.sh` - Automated test orchestrator
- `scripts/validate-network-disruption.sh` - Continuous connectivity monitor

### Documentation
- `docs/NETWORK_DISRUPTION_TEST_GUIDE.md` - Comprehensive testing guide

---

## Production Testing: Next Steps

Once you've validated the mechanism in AZ-D, you can test your production patterns:

### 1. Tag Production Subnets

```bash
# Primary AZ subnets (us-west-2b)
aws ec2 create-tags \
  --resources subnet-primary1 subnet-primary2 \
  --tags Key=FISTarget,Value=True Key=FISAZRole,Value=Primary

# Secondary AZ subnets (us-west-2a)
aws ec2 create-tags \
  --resources subnet-secondary1 subnet-secondary2 \
  --tags Key=FISTarget,Value=True Key=FISAZRole,Value=Secondary
```

### 2. Run Primary AZ Disruption

```bash
# Get template ID
TEMPLATE_ID=$(aws cloudformation describe-stacks \
  --stack-name fis-infrastructure \
  --query 'Stacks[0].Outputs[?OutputKey==`FISTemplateSubnetDisruptPrimaryAZId`].OutputValue' \
  --output text)

# Start experiment
aws fis start-experiment --experiment-template-id ${TEMPLATE_ID}
```

### 3. Validate HA Behavior

**Expected:**
- SQL Server DAG automatically fails over to Secondary AZ
- Lambda functions invoke from Secondary AZ subnets
- API Gateway requests route via Secondary AZ VPC endpoints
- Applications experience brief latency spike but no errors
- After 5 minutes: Primary AZ rejoins, replicas synchronize

---

## Architecture: Test vs Production

```
┌─────────────────────────────────────────────────────────────┐
│ VPC: 10.x.x.x/16 (Production) + 100.64.0.0/16 (Test)      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  AZ-A (us-west-2a) - OIH Production SECONDARY               │
│  ├─ 10.x.1.0/24                                             │
│  ├─ SQL Server Secondary, Lambda, API Gateway, RDS          │
│  └─ FISAZRole: Secondary                                    │
│                                                              │
│  AZ-B (us-west-2b) - OIH Production PRIMARY                 │
│  ├─ 10.x.2.0/24                                             │
│  ├─ SQL Server Primary, Lambda, API Gateway, RDS            │
│  └─ FISAZRole: Primary                                      │
│                                                              │
│  AZ-C (us-west-2c) - OIH Production                         │
│  └─ 10.x.3.0/24                                             │
│                                                              │
│  AZ-D (us-west-2d) - ISOLATED TEST ZONE                     │
│  ├─ 100.64.0.0/24 (RFC6598 - Carrier-Grade NAT space)      │
│  ├─ Test Lambda, Test EC2 (no production resources)         │
│  └─ FISAZRole: TestAZ                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Why This Is Smart:**
- AZ-D has **zero** production OIH resources
- RFC6598 space clearly separates test from production
- Can't accidentally disrupt anyone else's workloads
- Perfect sandbox for validating FIS behavior

---

## Troubleshooting

### Issue: VPC Lambda doesn't fail during disruption

**Cause**: Subnet not tagged correctly
**Fix**:
```bash
aws ec2 describe-subnets --subnet-ids ${TEST_SUBNET_ID} --query 'Subnets[0].Tags'
# Should show FISTarget: True and FISAZRole: TestAZ
```

### Issue: Experiment fails to start

**Cause**: No subnets match target tags
**Fix**:
```bash
aws ec2 describe-subnets \
  --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISAZRole,Values=TestAZ" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone]' \
  --output table
```

### Issue: Regional Lambda also fails

**Cause**: Lambda is actually VPC-attached (misconfiguration)
**Fix**:
```bash
aws lambda get-function-configuration \
  --function-name FIS-Test-Regional-Lambda \
  --query 'VpcConfig'
# Should return null
```

See `docs/NETWORK_DISRUPTION_TEST_GUIDE.md` for complete troubleshooting guide.

---

## Cleanup

```bash
# Delete test harness
aws cloudformation delete-stack --stack-name fis-test-harness

# Delete experiment template
TEMPLATE_ID=$(aws fis list-experiment-templates \
  --query 'experimentTemplates[?tags.Name==`OIH-Test-Subnet-Network-Disruption`].id' \
  --output text)
aws fis delete-experiment-template --id ${TEMPLATE_ID}

# Remove subnet tags
aws ec2 delete-tags \
  --resources ${TEST_SUBNET_ID} \
  --tags Key=FISTarget Key=FISAZRole
```

---

## Summary

This testing framework validates:

✅ **Network disruption isolates entire subnets** - all resources affected
✅ **Regional services unaffected** - disruption is AZ-specific
✅ **Automatic recovery works** - no manual intervention required
✅ **Safe for production** - predictable, time-bounded, self-healing

**You're now ready to confidently test OIH HA/DR patterns with subnet-level network disruption!**
