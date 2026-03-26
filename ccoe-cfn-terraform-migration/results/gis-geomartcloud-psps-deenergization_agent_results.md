# Repository Assessment: gis-geomartcloud-psps-deenergization

## 1. Overview
The repository contains a CloudFormation template for deploying a containerized application on AWS ECS Fargate with Lambda integration. The infrastructure includes ECS task definitions, IAM roles, logging, security groups, and Secrets Manager configuration.

## 2. Architecture Summary
- **Core Services**: ECS Fargate, Lambda, IAM, CloudWatch Logs, Secrets Manager
- **Pattern**: Serverless container orchestration with event-driven processing
- **Key Components**:
  - ECS Task Definition with Fargate launch type
  - Lambda function with VPC integration
  - SQS event source mapping for Lambda
  - Overly permissive IAM roles
  - Parameterized configuration via SSM and template parameters

## 3. Identified Resources
- ECS::TaskDefinition
- IAM::Role (ExecutionRole, TaskRole, LambdaRole)
- Logs::LogGroup
- Lambda::Function
- EC2::SecurityGroup
- SecretsManager::Secret
- Lambda::EventSourceMapping

## 4. Issues & Risks
- **Security**:
  - TaskRole has `s3:*` and `rds:*` permissions on all resources
  - LambdaRole has 14 policies with 11 using `Resource: "*"`
  - Missing encryption configuration for Secrets Manager
  - Lambda environment variables exposed in plaintext
  - SQS queue ARN hard-coded with account ID

- **Configuration**:
  - Duplicate parameters: pEnv/ptaskEnv, VPC/pVPCID
  - Unused parameters: pGroupId, account, pandas, psycopg, region
  - Lambda code contains commented-out placeholder
  - Hard-coded Lambda layer ARNs with region us-west-2

- **Reliability**:
  - No autoscaling configuration for ECS service
  - Missing error handling for Lambda

## 5. Technical Debt
- **Hardcoding**: Lambda layer ARNs, SQS ARN pattern
- **Modularization**: Single monolithic template
- **Parameter Sprawl**: Duplicated environment parameters
- **IAM Anti-Patterns**: Excessive wildcard permissions
- **Missing Lifecycle Controls**: No retention policies for logs

## 6. Terraform Migration Complexity
Moderate complexity due to:
- Need to decompose IAM policies
- Parameter reorganization
- Lambda environment variable handling
- ECS task definition translation
- Would require:
  - 1:1 resource mapping for most components
  - IAM policy refactoring
  - Lambda layer ARN parameter replacement

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - ECS task definitions
   - IAM roles
   - Lambda configuration
   - Security groups

2. Migrate parameters to Terraform variables with validation
3. Replace SSM parameter lookups with Terraform data sources
4. Decompose IAM policies into least-privilege statements
5. Add missing encryption configurations
6. Implement environment-specific variables

Use terraform import for state migration of:
- Existing log groups
- Secrets Manager secrets
- Security groups

