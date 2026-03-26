# Repository Assessment: gis-geomartcloud-pspsv4-batch-event-reports

## 1. Overview
The repository contains CloudFormation templates for deploying batch event reporting infrastructure in AWS. It includes Lambda functions, ECS tasks, IAM roles, security groups, and Secrets Manager configurations for multiple report types (data exception, missing segment, upstream SCADA, duplicate segment).

## 2. Architecture Summary
- **Core Services**: Lambda, ECS (Fargate), IAM, Secrets Manager, CloudWatch Logs, SQS
- **Pattern**: Event-driven architecture with SQS queues triggering Lambda functions that execute ECS tasks
- **Security**: Uses SSM Parameter Store for configuration, KMS for Lambda encryption, and Secrets Manager for sensitive values
- **Environments**: Supports prod/qa/tst/dev/trn environments through parameters

## 3. Identified Resources
- 4x Lambda Functions (dataexception, missingsegment, upstreamscada, duplicatesegment)
- 8x IAM Roles (Lambda execution + ECS task roles)
- 4x ECS Task Definitions
- 4x Security Groups
- 4x CloudWatch Log Groups
- 4x Secrets Manager Secrets
- 4x SQS Event Source Mappings

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies with Resource: "*" (e.g., s3:*, rds:*, ec2:*)
  - Missing ECS cluster configuration (referenced but not defined)
  - Hardcoded values in Secrets Manager (e.g., "subnet" key typo)
  - Public SQS ARN references without validation
  - Python 3.7 runtime (deprecated in Lambda)

- **Configuration**:
  - Duplicate SecurityGroupIngress resources with identical names
  - Missing VPC flow logs configuration
  - No retention policy on log groups
  - Hardcoded region in Lambda layer ARN

- **Operational**:
  - No autoscaling configuration
  - No dead-letter queue configuration
  - Missing ECS service discovery configuration

## 5. Technical Debt
- High resource duplication between report types
- No modularization (single monolithic template)
- Hardcoded values instead of parameters
- Inconsistent resource naming conventions
- Missing output exports for cross-stack references
- No lifecycle policies for resource cleanup

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Would require:
  - Refactoring IAM policies to use Terraform's aws_iam_policy_document
  - Decomposing into modules (lambda, ecs, iam)
  - Handling Secrets Manager JSON templating
  - Resolving missing ECS cluster dependency

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Lambda functions
   - ECS tasks
   - IAM roles
   - Security groups
2. Migrate parameters to Terraform variables
3. Convert core resources first (VPC, ECS cluster)
4. Implement state management strategy (remote backend)
5. Validate with CloudFormation drift detection
6. Incremental rollout per report type

