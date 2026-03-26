# aws-oih-fis

Fault Injection Service experiments supporting Outage Information Hub High Availability and Disaster Recovery Testing

## Executive Summary

The HA/DR testing for the Outage Information Hub (OIH) workload validates the ability to detect failures, perform fail-over, and recover from backup across critical components deployed in AWS. This repository provides Infrastructure as Code (CloudFormation) for comprehensive chaos engineering experiments that simulate failure scenarios from individual component failures to complete Availability Zone outages.

## Test Philosophy

**Hypothesis**: The OIH workload architecture is designed to survive a complete Availability Zone failure without human intervention.

**Approach**: Progressive failure testing from component-level disruptions to AZ-wide network isolation, validating autonomous detection, failover, and recovery mechanisms at each level.

## Test Scope

- Simulate component-level failures (disk, compute, network)
- Simulate complete Availability Zone (AZ) failures via subnet network disruption
- Validate autonomous detection of failure for key OIH components
- Confirm automatic fail-over capability for all services
- Ensure recovery from backup for core systems
- Test cross-AZ failover for SQL Server Database Availability Groups

## Environment

QA/Dev environment will be used for all tests unless otherwise noted.

## Experiment Templates

All experiment templates are managed via CloudFormation in [cfn/FIS_plumbing.yaml](cfn/FIS_plumbing.yaml).

### SQL Server HA/DR Testing (Component-Level)

#### EC2 Instance Failures

1. **Primary EC2 Stop** - Stops primary SQL Server instances, auto-restarts after 5 minutes
   - Tests: SQL DAG failover to secondary, connection string resilience
2. **Secondary EC2 Stop** - Stops secondary SQL Server instances, auto-restarts after 5 minutes
   - Tests: Degraded mode operation, DAG member loss handling

#### Storage Failures

1. **Primary EBS I/O Pause** - Pauses all I/O on primary database volumes for 5 minutes
   - Tests: Storage-level failure detection, SQL Server timeout handling
2. **Secondary EBS I/O Pause** - Pauses all I/O on secondary database volumes for 5 minutes
   - Tests: Replica synchronization failure, degraded replication

### Complete AZ Failure Simulation (Subnet-Level Network Isolation)

1. **Primary AZ Subnet Network Disruption** - Blocks ALL network traffic to/from all subnets in Primary AZ for 5 minutes
   - **Effect**: Simulates complete AZ outage (power loss, network failure, natural disaster) affecting ALL services in tagged subnets:
     - EC2 instances (SQL Server, application servers, etc.)
     - RDS databases (if in subnet)
     - Lambda functions (VPC-attached ENIs)
     - API Gateway private endpoints
     - ECS/Fargate tasks
     - Application Load Balancers
     - NAT Gateways
     - Any service with network presence in the subnet
   - **Tests**: Core hypothesis - workload survives complete AZ failure without human intervention

2. **Secondary AZ Subnet Network Disruption** - Blocks ALL network traffic to/from all subnets in Secondary AZ for 5 minutes
   - Same comprehensive impact as Primary AZ test

## Test Cases by Service

| Service               | FIS Native Support | Component Test | AZ Failure Test | Test Approach                                                                                         |
| --------------------- | ------------------ | -------------- | --------------- | ----------------------------------------------------------------------------------------------------- |
| EC2 Instances         | Yes                | ✅ Yes         | ✅ Yes          | Component: EC2 stop/start. AZ: Subnet network disruption                                             |
| SQL Server DAG        | Via EC2/EBS/Network| ✅ Yes         | ✅ Yes          | Component: Instance stop, EBS I/O pause, instance network disrupt. AZ: Subnet disruption             |
| Auto Scaling Groups   | Yes                | ✅ Yes         | ✅ Yes          | Component: Instance termination. AZ: Subnet disruption validates rebalancing                         |
| EBS Volumes           | Yes                | ✅ Yes         | ✅ Yes          | Component: I/O pause action. AZ: Subnet disruption affects all instances                             |
| RDS (Multi-AZ)        | Yes                | ✅ Planned     | ✅ Yes          | Component: FIS failover action. AZ: Subnet disruption (if RDS in VPC)                                |
| ElastiCache           | Yes                | ✅ Planned     | ✅ Yes          | Component: FIS node disruption. AZ: Subnet disruption                                                 |
| Lambda (VPC-attached) | Via Subnet         | ❌ N/A         | ✅ Yes          | AZ: Subnet network disruption affects Lambda ENIs - validates function resilience                     |
| API Gateway (Private) | Via Subnet         | ❌ N/A         | ✅ Yes          | AZ: Subnet disruption affects VPC endpoints - validates API failover                                  |
| DMS                   | Via Subnet         | ❌ N/A         | ✅ Yes          | AZ: Subnet disruption affects DMS replication instances (if VPC-based)                                |
| DynamoDB              | Regional           | ❌ N/A         | ✅ Indirect     | AZ: Validate application logic when VPC endpoint in failed AZ; DynamoDB itself is AZ-resilient        |
| S3                    | Regional           | ❌ N/A         | ✅ Indirect     | AZ: Validate access via remaining VPC endpoints when one AZ fails                                     |
| CloudFront            | Global             | ❌ N/A         | ✅ Indirect     | AZ: Validate origin failover when origin AZ fails via subnet disruption                              |

## SQL Server Failure Testing Matrix

Testing validates three failure boundaries for SQL Server Database Availability Groups:

1. **Disk Failure** (EBS I/O Pause experiments)
   - Simulates: SAN failure, storage controller failure, volume corruption
   - Duration: 5 minutes
   - Expected: SQL Server timeouts, DAG failover to healthy replica

2. **Server Failure** (EC2 Stop experiments)
   - Simulates: Hardware failure, OS crash, hypervisor failure
   - Duration: 5 minutes (with auto-restart)
   - Expected: Immediate DAG failover, automatic rejoin on restart

3. **Network/Connectivity Failure** (Network Disruption experiments)
   - Simulates: Switch failure, network partition, AZ isolation
   - Duration: 5 minutes
   - Expected: Quorum loss detection, DAG failover, connection string routing

## Tagging Strategy

### Instance and Volume Tags (Component-Level Testing)

```bash
# EC2 Instances
FISTarget: True
FISDBRole: Primary|Secondary

# EBS Volumes (requires ALL three tags)
FISTarget: True
FISEBSTarget: True
FISDBRole: Primary|Secondary
```

### Subnet Tags (AZ-Level Failure Testing)

```bash
# Subnets in Primary AZ
FISTarget: True
FISAZRole: Primary

# Subnets in Secondary AZ
FISTarget: True
FISAZRole: Secondary
```

**Interactive Tagging Scripts:**

- **Component-level experiments (EC2/EBS)**: [scripts/tag-resources-for-fis.sh](scripts/tag-resources-for-fis.sh)
- **AZ-level experiments (Subnets)**: [scripts/tag-subnets-for-fis.sh](scripts/tag-subnets-for-fis.sh)

See [docs/TAGGING_SCRIPTS_GUIDE.md](docs/TAGGING_SCRIPTS_GUIDE.md) for detailed usage guide.

## Deployment

### Initial Setup

```bash
# Deploy FIS infrastructure (IAM role, log groups, S3 bucket, all experiment templates)
aws cloudformation create-stack \
  --stack-name fis-infrastructure \
  --template-body file://cfn/FIS_plumbing.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

### Updates

```bash
# Update stack with new experiment templates
./scripts/update-fis-stack.sh
```

## Running Experiments

### Get Template IDs

```bash
aws cloudformation describe-stacks \
  --stack-name fis-infrastructure \
  --query 'Stacks[0].Outputs[?OutputKey==`FISTemplatePrimaryEC2StopId`].OutputValue' \
  --output text
```

### Start an Experiment

```bash
# Component-level test (e.g., stop primary SQL Server instances)
aws fis start-experiment --experiment-template-id <TEMPLATE_ID>

# AZ-level test (e.g., simulate complete Primary AZ failure)
aws fis start-experiment --experiment-template-id <SUBNET_DISRUPT_PRIMARY_AZ_TEMPLATE_ID>
```

### Monitor Experiments

- **Console**: AWS FIS Console → Experiments
- **CloudWatch Logs**: `/aws/fis/experiments`
- **S3 Logs**: `s3://oih-dev-fis-logs/experiments/`

## SQL Server DAG Discovery

Use the SSM document to discover which instance is currently serving as the SQL Server primary:

```bash
aws ssm send-command \
  --document-name "DiscoverSQLDAGPrimary" \
  --targets "Key=tag:FISTarget,Values=True" \
  --comment "Discover SQL Server DAG primary replica"
```

See: [ssm-documents/discover-sql-dag-primary.yaml](ssm-documents/discover-sql-dag-primary.yaml)

## Key Features

- **Full IaC**: All experiments defined in CloudFormation
- **Tag-Based Targeting**: No hardcoded instance IDs or AZs
- **Comprehensive Logging**: CloudWatch Logs + S3 with separate prefixes per experiment type
- **Auto-Recovery**: EC2 experiments automatically restart instances after testing
- **Safety Controls**: Multi-tag requirements, state filters, explicit targeting
- **Progressive Testing**: Component-level → AZ-level failure scenarios

## Future Enhancements

- RDS failover experiments
- ElastiCache node disruption experiments
- Cross-region DR testing
- Compound failure scenarios (multiple simultaneous failures)
- Automated validation and rollback
