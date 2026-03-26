# Repository Assessment: gis-geomartcloud-psps-allaffectedcustomer

## 1. Overview
This CloudFormation template deploys a containerized application on AWS Fargate with Lambda integration for event processing. Uses SSM parameters for configuration management and includes IAM roles with broad permissions. Targets geospatial data processing workloads.

## 2. Architecture Summary
- **Core Services**: ECS Fargate (container orchestration), Lambda (event-driven processing), Secrets Manager (configuration storage), CloudWatch Logs (logging)
- **Pattern**: Microservices architecture with serverless compute and containerized backend
- **Networking**: Lambda deployed in VPC with private subnets
- **Security**: Uses IAM roles but contains overly permissive policies

## 3. Identified Resources
- ECS::TaskDefinition
- IAM::Role (ExecutionRole, TaskRole, LambdaRole)
- Logs::LogGroup
- Lambda::Function + Security Group
- SecretsManager::Secret
- Lambda::EventSourceMapping (SQS integration)

## 4. Issues & Risks
- **Security**:
  - TaskRole has s3:* and rds:* permissions (violates least privilege)
  - LambdaRole has ec2:* and rds:* permissions
  - Missing encryption settings for LogGroup and SecretsManager
  - Lambda VPC configuration uses private subnets but no NAT gateway reference
- **Configuration**:
  - Duplicate environment parameters (pEnv and ptaskEnv)
  - Hardcoded us-west-2 region in Lambda layers
  - Missing ECS Cluster declaration (commented out)
  - SQS queue ARN uses ${region} variable not declared in Parameters
- **Reliability**:
  - No autoscaling configuration for ECS Service
  - No dead-letter queue for Lambda event source

## 5. Technical Debt
- **Hardcoding**: Lambda layer ARNs hardcode us-west-2
- **Modularization**: Single monolithic template instead of nested stacks
- **Parameter Sprawl**: Redundant VPC/pVPCID parameters
- **Missing Lifecycle**: No retention policies for logs
- **Environment Handling**: Case inconsistency between pEnv (lowercase) and ptaskEnv (uppercase)

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (ECS, IAM, Lambda)
- Requires:
  - Refactoring SSM parameter references to Terraform data sources
  - Decomposing inline policies into managed policies
  - Handling DependsOn relationships with Terraform dependencies
  - Addressing hardcoded values through variables

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state bucket with versioning
   - Define environment variables for accounts/regions

2. **Core Infrastructure**:
   - Migrate VPC/subnet references to data sources
   - Create IAM roles first with cleaned-up policies
   - Implement SecretsManager secret with proper encryption

3. **ECS Components**:
   - Convert TaskDefinition with explicit dependency handling
   - Add missing ECS Cluster resource
   - Implement service autoscaling configuration

4. **Lambda Migration**:
   - Parameterize

