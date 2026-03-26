# Repository Assessment: pge-secinfra

## 1. Overview
This CloudFormation template provisions QRadar security infrastructure including optional EC2 instances, security groups, SQS queues for log aggregation, IAM roles, and KMS encryption keys. It supports multiple log sources (Linux, WAF, CloudTrail, VPC Flow Logs) and environment configurations.

## 2. Architecture Summary
- **Core Components**: EC2 instances (RedHat/QRadar), security groups, SQS queues, IAM roles
- **Log Integration**: Uses SQS queues to collect logs from S3 buckets (Linux, WAF, CloudTrail, VPC Flow)
- **Security**: KMS encryption for SQS queues, restricted security group rules
- **Scalability**: Conditional resource creation based on parameters

## 3. Identified Resources
- 1x EC2 Prefix List
- 1x Security Group
- 2x EC2 Instances (conditional)
- 1x IAM Instance Profile
- 1x IAM Role
- 5x SQS Queues (conditional)
- 5x SQS Queue Policies (conditional)
- 1x KMS Key
- 1x KMS Alias

## 4. Issues & Risks
- **Security Group Exposure**: Hardcoded 10.0.0.0/8 CIDR allows SSH/HTTPS from entire VPC
- **IAM Over-Permissions**:
  - SQS policies grant wildcard (*) access
  - KMS key policy allows root full access
  - IAM role has hardcoded ARNs for non-standard accounts
- **Data Consistency**: Duplicate SNMP server entries in prefix list
- **Missing Resources**:
  - No S3 buckets defined (assumed to exist externally)
  - No VPC endpoints shown
- **Hardcoded Values**: Default environment=PROD, static timestamps

## 5. Technical Debt
- **Parameter Sprawl**: 26 parameters with overlapping purposes
- **Tight Coupling**: Security group and IAM role tightly bound to instance configuration
- **Environment Handling**: Uses parameter defaults instead of stack-level configuration
- **Missing Lifecycle Management**: No termination protection or update policies

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires decomposition of:
  - Security group rules
  - IAM policy documents
  - SQS queue configurations
- Challenges with:
  - Prefix list entries (requires count/for_each)
  - Conditional resources (Terraform's count vs CFN Conditions)
  - KMS key policy formatting

## 7. Recommended Migration Path
1. **IAM First**: Migrate IAM roles/policies first to establish permissions
2. **Security Primitives**: Create KMS key and security groups
3. **Core Infrastructure**: Implement EC2 instances and SQS queues
4. **Validation**: Verify queue policies and S3 integration
5. **Parameterization**: Replace hardcoded values with Terraform variables
6. **Modularization**: Break into modules (networking, compute, logging)

