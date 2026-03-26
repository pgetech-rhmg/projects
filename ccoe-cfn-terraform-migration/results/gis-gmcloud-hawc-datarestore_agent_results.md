# Repository Assessment: gis-gmcloud-hawc-datarestore

## 1. Overview
The CloudFormation template provisions infrastructure for a containerized ETL (Extract-Transform-Load) data restoration service using AWS Fargate, IAM roles, and Secrets Manager. The solution focuses on deploying ECS tasks with appropriate permissions while maintaining security compliance through tagging and restricted access patterns.

## 2. Architecture Summary
The architecture uses:
- **ECS Fargate** for serverless container orchestration
- **IAM Roles** with least-privilege policies for task execution and resource access
- **CloudWatch Logs** for centralized logging
- **Secrets Manager** for secure configuration storage
- **VPC Security Groups** for network isolation

Primary patterns:
- Parameter-driven configuration via SSM Parameter Store
- Environment-aware resource naming
- Security-first design with compliance tagging

## 3. Identified Resources
- AWS::ECS::TaskDefinition
- AWS::IAM::Role (execution + task roles)
- AWS::Logs::LogGroup
- AWS::EC2::SecurityGroup
- AWS::EC2::SecurityGroupIngress
- AWS::SecretsManager::Secret

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: TaskRole has s3:*, kms:*, rds:* permissions
- **Missing Parameter Validation**: pMemory lacks constraints (should match CPU requirements)
- **Hardcoded Security Group Name**: rSecurityGroup uses static name (risk of collision)
- **Inconsistent Environment Parameters**: pEnv vs pTaskEnv casing mismatch
- **Unrestricted Resource Access**: Many policies use Resource: "*"
- **Missing Outputs**: Critical values like TaskDefinition ARN aren't exported

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with overlapping purposes
- **Hardcoded Values**: Security group name and some policy actions
- **No Environment Separation**: Single template for all environments
- **No Lifecycle Management**: No retention policies for logs/secrets

## 6. Terraform Migration Complexity
Moderate complexity:
- Direct mappings exist for most resources
- Requires:
  - Refactoring SSM parameters to Terraform data sources
  - Decomposing into modules (IAM/ECS/networking)
  - Converting Fn::Sub/Join syntax
  - Handling dependencies explicitly

## 7. Recommended Migration Path
1. Create Terraform data sources for SSM parameters
2. Build IAM module for roles and policies
3. Migrate LogGroup and SecurityGroup resources
4. Convert TaskDefinition with explicit dependency management
5. Implement SecretsManager resource with string interpolation
6. Validate all parameters with proper constraints

Use Terraform workspaces for environment separation and maintain parameter hierarchy through variable files.

