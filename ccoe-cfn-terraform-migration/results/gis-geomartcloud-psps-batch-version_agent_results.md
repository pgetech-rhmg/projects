# Repository Assessment: gis-geomartcloud-psps-batch-version

## 1. Overview
This CloudFormation template deploys a batch processing pipeline using AWS Lambda and Step Functions. It includes VPC-enabled Lambda functions, IAM roles, security groups, and SQS event triggers for geospatial data processing workflows.

## 2. Architecture Summary
- **Core Services**: Lambda, Step Functions, IAM, VPC, SQS
- **Pattern**: Event-driven batch orchestration with parallel processing branches
- **Workflow**: SQS triggers Lambda → Step Functions orchestrates 5-stage pipeline (SSDCalculation → [DeviceCache|IsolationZone] → DropTempTables)

## 3. Identified Resources
- IAM Roles (2)
- Security Group (1) with self-referencing ingress
- Lambda Functions (5) with VPC configuration
- Step Functions State Machine (1)
- SQS Event Source Mapping (1)

## 4. Issues & Risks
- **Security**: 
  - Overly permissive IAM policies with 14x Resource:"*" statements
  - Missing encryption enforcement for S3/RDS operations
  - Public SQS ARN reference (security risk if real)
  - Deprecated Python 3.7 runtime (end-of-support 2023-06-27)
- **Configuration**:
  - Hardcoded VPC region (us-west-2) in layer ARNs
  - Security group description mismatch ("for RDS" but used by Lambda)
  - Missing dead-letter queue configuration

## 5. Technical Debt
- Inline IAM policies instead of managed policies
- Hardcoded values in Lambda code blocks
- No environment-specific resource naming
- No parameter for Lambda memory/timeout
- No KMS key management for sensitive operations

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings for most resources
- Requires:
  - Refactoring inline policies to managed
  - Modularization into Lambda/SF/VPC modules
  - Parameterization of hardcoded values
  - State machine JSON conversion

## 7. Recommended Migration Path
1. Extract inline policies to Terraform aws_iam_policy
2. Create Lambda module with VPC config
3. Convert StepFunctions JSON to HCL
4. Parameterize all hardcoded values
5. Validate with terraform plan

