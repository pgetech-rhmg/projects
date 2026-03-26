# Repository Assessment: gis-geomartcloud-psps-postdeenergization

## 1. Overview
This CloudFormation template deploys a containerized application infrastructure using ECS Fargate, Lambda functions, and supporting resources. It includes environment-specific configuration, IAM roles, logging, and secrets management.

## 2. Architecture Summary
- **Core Services**: ECS Fargate (container orchestration), Lambda (event processing), Secrets Manager (configuration storage), CloudWatch Logs (logging)
- **Pattern**: Serverless container deployment with event-driven Lambda triggers
- **Environment Handling**: Uses SSM parameters for environment-specific configuration

## 3. Identified Resources
- ECS::TaskDefinition
- IAM::Role (ExecutionRole, TaskRole, LambdaRole)
- Logs::LogGroup
- Lambda::Function + Security Group
- SecretsManager::Secret
- Lambda::EventSourceMapping (SQS integration)

## 4. Issues & Risks
- **Security**: 
  - Overly permissive IAM policies (Resource: "*" in TaskRole and LambdaRole)
  - Missing encryption configuration for Secrets Manager
  - Public IP assignment disabled but not explicitly enforced
  - Lambda environment variables exposed in template
- **Configuration**:
  - Duplicated environment parameters (pEnv and ptaskEnv)
  - Hardcoded AWS region in Lambda layer ARNs
  - Missing ECS Cluster/Service definitions

## 5. Technical Debt
- **Parameter Management**: 
  - Redundant VPC/pVPCID parameters
  - Inconsistent casing in environment parameters
- **Hardcoding**: 
  - Fixed region in Lambda layers
  - Magic numbers for CPU/Memory configurations
- **Modularization**: Single monolithic template instead of nested stacks

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean mappings exist for ECS, Lambda, and IAM resources
- Requires:
  - Refactoring SSM parameter references
  - Decomposing monolithic template into modules
  - Handling !Sub syntax differences
  - Addressing missing resource dependencies

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state backend configuration
   - Establish parameter mapping layer for SSM values

2. **Module Structure**:
   - ecs/ (task definition, execution role)
   - lambda/ (function, role, security group)
   - core/ (networking, logging)

3. **Incremental Migration**:
   - Start with IAM roles and policies
   - Migrate logging infrastructure
   - Convert ECS task definition
   - Implement Lambda function and event mapping last

4. **Security Improvements**:
   - Add SecretsManager encryption during migration
   - Implement least-privilege IAM policies
   - Parameterize all environment-specific values

