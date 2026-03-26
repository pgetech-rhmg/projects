# Repository Assessment: gis-gmcloud-hawc-databackup

## 1. Overview
This CloudFormation template provisions infrastructure for a containerized ETL data backup solution using AWS ECS Fargate, IAM roles, and CloudWatch logging. The configuration includes environment-specific parameters, security controls, and resource tagging.

## 2. Architecture Summary
- **Core Services**: ECS Fargate (task definitions), IAM roles, Secrets Manager, CloudWatch Logs
- **Pattern**: Microservices deployment pattern using container orchestration
- **Security**: Parameter Store integration for secrets, environment-specific IAM roles
- **Observability**: CloudWatch logging for container output

## 3. Identified Resources
- ECS::TaskDefinition
- IAM::Role (execution + task roles)
- Logs::LogGroup
- EC2::SecurityGroup
- SecretsManager::Secret

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: TaskRole has s3:*, kms:*, rds:*, and 20+ other services with full access
- **Hardcoded Security Group**: rSecurityGroupIngress allows all protocols (-1) from self
- **Missing VPC Endpoints**: S3/KMS access may require VPC endpoints for private subnets
- **Inconsistent Parameter Names**: pTaskEnv vs pEnv casing mismatch
- **Unused Parameters**: pGlueVersion exists but no Glue resources deployed
- **Secrets Manager Exposure**: ECS secret contains sensitive configuration details

## 5. Technical Debt
- **Parameter Sprawl**: 20+ parameters with inconsistent naming conventions
- **Hardcoded Values**: Resource policies contain "*" resources and fixed memory/CPU values
- **Tight Coupling**: Security group references itself creating dependency loop risk
- **Missing Lifecycle Management**: No retention policies for logs

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for ECS, IAM, and logging resources
- Would require:
  - Refactoring parameters into variables
  - Modularizing into resource-specific modules
  - Converting Fn::Sub/Join syntax
  - Addressing DependsOn relationships

## 7. Recommended Migration Path
1. Create Terraform variables from CFN parameters
2. Build core modules: 
   - ecs_task (task definition + execution role)
   - iam (task role + policies)
   - logging
3. Migrate stateful resources first (LogGroup)
4. Implement gradual rollout:
   - Deploy IAM roles
   - Validate ECS task configuration
   - Migrate Secrets Manager integration
5. Use Terraform data sources for SSM parameter lookups

