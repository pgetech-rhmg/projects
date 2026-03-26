# FIS Network Disruption Validation Test Guide

## Overview

This guide walks through validating the FIS `aws:network:disrupt-connectivity` action in your isolated AZ-D test subnet before running experiments against production OIH resources.

## How Network Disruption Works

### Mechanism
- **FIS Action**: `aws:network:disrupt-connectivity`
- **Target**: Subnets (entire subnets, not individual resources)
- **Scope**: `all` = blocks both ingress AND egress traffic
- **Implementation**: FIS temporarily modifies the subnet's **Network ACLs** to DENY ALL traffic
- **Duration**: 5 minutes (configurable)
- **Recovery**: Automatic - FIS restores original Network ACLs after duration

### What Gets Isolated

When you disrupt a subnet, **ALL** network interfaces in that subnet become isolated:

| Resource Type | Effect During Disruption |
|---------------|--------------------------|
| **EC2 Instances** | No SSH, RDP, SSM, application traffic - completely isolated |
| **Lambda (VPC-attached)** | Cannot be invoked - timeout errors |
| **API Gateway (Private)** | VPC endpoint ENIs unreachable - API calls fail |
| **RDS Instances** | Database connections timeout |
| **Load Balancers** | Health checks fail, traffic stops routing |
| **NAT Gateways** | Outbound traffic from subnet blocked |
| **VPC Endpoints** | Service endpoints unreachable |

### What Does NOT Get Isolated

- **Regional Lambda** (no VPC attachment) - works normally
- **CloudFront** - continues serving cached content
- **S3** (direct access) - works normally
- **DynamoDB** (direct access) - works normally
- Resources in **other subnets** - completely unaffected

---

## Test Architecture

You've created an isolated test environment:

```
VPC: 10.x.x.x/16 (existing production CIDR)
  ├── AZ-A: 10.x.1.0/24 (OIH Production - PRIMARY)
  ├── AZ-B: 10.x.2.0/24 (OIH Production - SECONDARY)
  ├── AZ-C: 10.x.3.0/24 (OIH Production)
  └── Secondary CIDR: 100.64.0.0/16 (RFC6598 - Carrier-Grade NAT space)
        └── AZ-D: 100.64.0.0/24 (ISOLATED TEST SUBNET) ← Your test zone
```

**Why This Is Smart:**
- AZ-D has **zero** existing OIH resources
- RFC6598 space clearly separates test from production
- Can't accidentally disrupt anyone else's Lambda/API Gateway
- Perfect sandbox for chaos engineering validation

---

## Test Harness Deployment

### Step 1: Deploy Test Resources

```bash
cd /Users/BDG3/code/aws/cfn/aws-oih-fis

# Get your test subnet ID
TEST_SUBNET_ID="subnet-xxxxxxxxx"  # Your AZ-D subnet
VPC_ID="vpc-xxxxxxxxx"             # Your VPC ID

# Deploy test harness
aws cloudformation create-stack \
  --stack-name fis-test-harness \
  --template-body file://cfn/FIS_test_harness.yaml \
  --parameters \
    ParameterKey=VpcId,ParameterValue=${VPC_ID} \
    ParameterKey=TestSubnetId,ParameterValue=${TEST_SUBNET_ID} \
    ParameterKey=TestSubnetCIDR,ParameterValue=100.64.0.0/24 \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for completion
aws cloudformation wait stack-create-complete --stack-name fis-test-harness

# Get outputs
aws cloudformation describe-stacks \
  --stack-name fis-test-harness \
  --query 'Stacks[0].Outputs' \
  --output table
```

This creates:
- ✅ **VPC Lambda** - Has ENI in your AZ-D subnet (will be isolated)
- ✅ **Regional Lambda** - No VPC attachment (control - should always work)
- ✅ **EC2 Instance** - In AZ-D subnet (will be isolated)
- ✅ **Security Groups** - Allow HTTPS/ICMP for testing
- ✅ **CloudWatch Logs** - Function execution logs

### Step 2: Tag the Test Subnet for FIS Targeting

```bash
# Tag your test subnet so FIS can target it
aws ec2 create-tags \
  --resources ${TEST_SUBNET_ID} \
  --tags \
    Key=FISTarget,Value=True \
    Key=FISAZRole,Value=TestAZ \
    Key=Name,Value=FIS-Test-Subnet-AZ-D \
    Key=Purpose,Value=Network-Disruption-Validation

# Verify tags
aws ec2 describe-subnets \
  --subnet-ids ${TEST_SUBNET_ID} \
  --query 'Subnets[0].Tags' \
  --output table
```

### Step 3: Create the FIS Experiment Template

```bash
# Create experiment template for test subnet
aws fis create-experiment-template \
  --cli-input-yaml file://fis-templates/test-subnet-disruption.yaml

# Get the template ID
TEMPLATE_ID=$(aws fis list-experiment-templates \
  --query 'experimentTemplates[?tags.Name==`OIH-Test-Subnet-Network-Disruption`].id' \
  --output text)

echo "Test Experiment Template ID: ${TEMPLATE_ID}"
```

---

## Pre-Flight Validation

Before running the disruption experiment, verify baseline connectivity:

### Test 1: VPC Lambda (Should Work)

```bash
# Invoke VPC-attached Lambda
aws lambda invoke \
  --function-name FIS-Test-VPC-Lambda \
  --log-type Tail \
  /tmp/vpc-test.json

# Check response
cat /tmp/vpc-test.json | jq
```

**Expected Output:**
```json
{
  "statusCode": 200,
  "body": {
    "timestamp": "2025-01-29T10:30:00.123456",
    "function_name": "FIS-Test-VPC-Lambda",
    "tests": {
      "execution": "SUCCESS",
      "dns_resolution": "SUCCESS",
      "external_connectivity": "SUCCESS (NAT IP: x.x.x.x)",
      "vpc_eni": "SUCCESS (function has VPC ENI in subnet)"
    }
  }
}
```

### Test 2: Regional Lambda (Should Work)

```bash
# Invoke Regional Lambda (control)
aws lambda invoke \
  --function-name FIS-Test-Regional-Lambda \
  --log-type Tail \
  /tmp/regional-test.json

cat /tmp/regional-test.json | jq
```

**Expected Output:**
```json
{
  "statusCode": 200,
  "body": {
    "message": "Regional Lambda responding - NOT affected by subnet disruption",
    "vpc_attached": false
  }
}
```

### Test 3: EC2 SSM Access (Should Work)

```bash
# Start SSM session to test EC2 instance
EC2_INSTANCE_ID=$(aws cloudformation describe-stacks \
  --stack-name fis-test-harness \
  --query 'Stacks[0].Outputs[?OutputKey==`TestEC2InstanceId`].OutputValue' \
  --output text)

aws ssm start-session --target ${EC2_INSTANCE_ID}

# Once connected, test outbound connectivity
curl -s https://checkip.amazonaws.com
# Should return public IP

# Exit session
exit
```

---

## Running the Disruption Test

### Terminal 1: Start Continuous Monitoring

```bash
cd /Users/BDG3/code/aws/cfn/aws-oih-fis/scripts

# Make script executable
chmod +x validate-network-disruption.sh

# Start continuous testing (tests every 10 seconds)
./validate-network-disruption.sh FIS-Test-VPC-Lambda FIS-Test-Regional-Lambda 10
```

You'll see continuous output like:
```
[Test #1] 2025-01-29 10:35:00 UTC
------------------------------------------------------------
✓ VPC Lambda: Invocation SUCCESS | DNS: SUCCESS | External: SUCCESS (NAT IP: x.x.x.x)
✓ Regional Lambda: Invocation SUCCESS (control - should always work)

[Test #2] 2025-01-29 10:35:10 UTC
------------------------------------------------------------
✓ VPC Lambda: Invocation SUCCESS | DNS: SUCCESS | External: SUCCESS (NAT IP: x.x.x.x)
✓ Regional Lambda: Invocation SUCCESS (control - should always work)
```

### Terminal 2: Start the FIS Experiment

```bash
# Start the network disruption experiment
aws fis start-experiment \
  --experiment-template-id ${TEMPLATE_ID} \
  --tags Name=Test-Subnet-Disruption-$(date +%Y%m%d-%H%M%S)

# Get experiment ID from output
EXPERIMENT_ID="<experiment-id-from-output>"

# Monitor experiment status
watch -n 5 "aws fis get-experiment --id ${EXPERIMENT_ID} --query 'experiment.state.status' --output text"
```

### What You'll Observe

**Phase 1: Pre-Disruption (before FIS starts)**
```
✓ VPC Lambda: Invocation SUCCESS
✓ Regional Lambda: Invocation SUCCESS
```

**Phase 2: During Disruption (5 minutes)**
```
✗ VPC Lambda: Invocation FAILED - Timeout or network isolation
✓ Regional Lambda: Invocation SUCCESS (control - should always work)
```

**Key Observations:**
- VPC Lambda **invocations timeout** (Lambda can't reach its ENI in the isolated subnet)
- Regional Lambda **continues working** (not affected by subnet disruption)
- EC2 instance **loses SSM connectivity** (can't establish new sessions)
- CloudWatch Logs show timeout errors for VPC Lambda

**Phase 3: Post-Disruption (automatic recovery after 5 minutes)**
```
✓ VPC Lambda: Invocation SUCCESS
✓ Regional Lambda: Invocation SUCCESS
```

- FIS automatically restores Network ACLs
- Connectivity resumes immediately
- No manual intervention required

---

## Validation Checklist

### ✅ Pre-Test Validation
- [ ] Test subnet tagged with `FISTarget: True` and `FISAZRole: TestAZ`
- [ ] VPC Lambda successfully invokes with external connectivity
- [ ] Regional Lambda successfully invokes
- [ ] EC2 instance reachable via SSM
- [ ] CloudWatch Logs showing normal function execution

### ✅ During-Test Validation
- [ ] VPC Lambda invocations **timeout/fail** within seconds of experiment start
- [ ] Regional Lambda **continues working** normally (control)
- [ ] Cannot establish new SSM sessions to EC2 instance
- [ ] CloudWatch Logs show Lambda timeout errors
- [ ] FIS experiment status shows "Running"

### ✅ Post-Test Validation
- [ ] VPC Lambda resumes working after 5 minutes (automatic recovery)
- [ ] Regional Lambda still working (never stopped)
- [ ] Can establish new SSM sessions to EC2 instance
- [ ] CloudWatch Logs show successful Lambda executions
- [ ] FIS experiment status shows "Completed"
- [ ] No manual intervention required for recovery

---

## Understanding the Results

### Success Criteria

Your test is successful if:

1. **Isolation Confirmed**: VPC Lambda fails during disruption
2. **Scope Validated**: Regional Lambda continues working (disruption is subnet-specific)
3. **Automatic Recovery**: Everything resumes working after 5 minutes without manual intervention
4. **No Blast Radius**: Resources in other subnets unaffected

### What This Proves

This validation demonstrates:

✅ **Network disruption works at the subnet level** - affects ALL resources in the subnet
✅ **Disruption is complete** - both ingress and egress blocked
✅ **Regional services unaffected** - Lambda without VPC attachment works normally
✅ **Automatic recovery works** - FIS restores connectivity after duration
✅ **Safe to use on production patterns** - you can confidently run this against OIH Primary/Secondary AZs

---

## Next Steps: Production Testing

Once you've validated the mechanism in AZ-D, you can confidently test your HA patterns:

### 1. SQL Server DAG Failover Test

**Hypothesis**: SQL Server DAG automatically fails over when Primary AZ loses network connectivity

**Test**: Disrupt Primary AZ subnets (us-west-2b)

```bash
# Tag Primary AZ subnets
aws ec2 create-tags \
  --resources subnet-xxxxx subnet-yyyyy \
  --tags Key=FISTarget,Value=True Key=FISAZRole,Value=Primary

# Run Primary AZ disruption
TEMPLATE_ID=$(aws cloudformation describe-stacks \
  --stack-name fis-infrastructure \
  --query 'Stacks[0].Outputs[?OutputKey==`FISTemplateSubnetDisruptPrimaryAZId`].OutputValue' \
  --output text)

aws fis start-experiment --experiment-template-id ${TEMPLATE_ID}
```

**Expected Behavior:**
- Primary SQL Server instance isolated
- DAG detects loss of quorum
- Automatic failover to Secondary replica (us-west-2a)
- Applications reconnect via AG listener
- After 5 minutes: Primary rejoins DAG and synchronizes

### 2. Multi-Service HA Test

**Hypothesis**: All OIH services (Lambda, API Gateway, RDS, DMS) survive Primary AZ failure

**Validation:**
- API Gateway requests continue via Secondary AZ VPC endpoint
- Lambda functions invoke from Secondary AZ subnets
- RDS Multi-AZ fails over to Secondary
- DMS replication continues (if instance in Secondary)
- Applications experience brief latency spike but no errors

---

## Troubleshooting

### VPC Lambda Doesn't Fail During Disruption

**Possible Causes:**
1. Subnet not tagged correctly (`FISTarget: True` and `FISAZRole: TestAZ`)
2. Lambda has ENIs in multiple subnets (only one disrupted)
3. Lambda timeout too short (increase to 30+ seconds to observe timeout)

**Debug:**
```bash
# Verify subnet tags
aws ec2 describe-subnets --subnet-ids ${TEST_SUBNET_ID} --query 'Subnets[0].Tags'

# Verify Lambda VPC config
aws lambda get-function-configuration --function-name FIS-Test-VPC-Lambda --query 'VpcConfig'

# Check FIS experiment logs
aws logs tail /aws/fis/experiments --follow
```

### Regional Lambda Also Fails

**Possible Causes:**
1. Lambda is actually VPC-attached (check configuration)
2. Your AWS CLI is running from within the disrupted subnet
3. IAM permissions issue (unrelated to FIS)

**Debug:**
```bash
# Verify Lambda has no VPC config
aws lambda get-function-configuration \
  --function-name FIS-Test-Regional-Lambda \
  --query 'VpcConfig'
# Should return null or empty
```

### Experiment Fails to Start

**Possible Causes:**
1. No subnets match the target tags
2. FIS role lacks permissions
3. Subnet in different region

**Debug:**
```bash
# Check target selection
aws ec2 describe-subnets \
  --filters "Name=tag:FISTarget,Values=True" "Name=tag:FISAZRole,Values=TestAZ" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]' \
  --output table

# Check FIS role
aws iam get-role --role-name FISExperimentRole
```

---

## Cleanup

When you're done testing:

```bash
# Delete the test harness stack
aws cloudformation delete-stack --stack-name fis-test-harness

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name fis-test-harness

# Delete FIS experiment template
aws fis delete-experiment-template --id ${TEMPLATE_ID}

# Optionally: Remove tags from test subnet
aws ec2 delete-tags \
  --resources ${TEST_SUBNET_ID} \
  --tags Key=FISTarget Key=FISAZRole

# Optionally: Delete test subnet and secondary CIDR (if no longer needed)
# (Manual cleanup via console recommended for VPC changes)
```

---

## Summary

You've validated that:

1. **FIS network disruption works** - completely isolates subnet for specified duration
2. **Isolation is complete** - both ingress and egress blocked, affecting ALL resources
3. **Regional services unaffected** - Lambda without VPC works normally
4. **Recovery is automatic** - no manual intervention required
5. **Safe for production testing** - predictable, time-bounded, self-healing

You're now ready to run network disruption experiments against your OIH Primary and Secondary AZ subnets with confidence!
