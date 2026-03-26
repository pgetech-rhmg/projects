# Repository Assessment: gis-geomartcloud-psps-etl-customerparceldatasync

## 1. Overview
The CloudFormation template provisions infrastructure for a geospatial ETL pipeline focused on customer parcel data synchronization. Key components include ECS Fargate tasks for geocoding, AWS Glue jobs for batch processing, and Secrets Manager for configuration management.

## 2. Architecture Summary
- **Core Services**: ECS Fargate (container orchestration), AWS Glue (ETL jobs), Secrets Manager (configuration), CloudWatch Logs (logging)
- **Pattern**: Microservices architecture with event-driven ETL processing
- **Data Flow**: Glue jobs trigger ECS tasks that process data from S3 and interact with RDS databases

## 3. Identified Resources
- ECS::TaskDefinition (2x)
- IAM::Role (3x)
- Logs::LogGroup (2x)
- Glue::Job (1x)
- Glue::Trigger (1x)
- SecretsManager::Secret (2x)
- EC2::SecurityGroup (1x)
- EC2::SecurityGroupIngress (1x)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (s3:*, rds:*, ec2:*, iam:*)
  - Glue role has ecs:* and ecr:* permissions
  - Lambda security group allows all inbound traffic from itself
  - Missing encryption configuration for Secrets Manager
- **Configuration**:
  - Hardcoded default values (pCFNOwnerTag, pOrderNumber)
  - CPU/Memory combinations may violate Fargate constraints
  - No VPC endpoint configurations for Glue
- **Reliability**:
  - No dead-letter queues for failure handling
  - Glue job timeout set to 10 minutes (may need adjustment)

## 5. Technical Debt
- **Modularization**: Single template handles multiple concerns (ECS, Glue, IAM)
- **Hardcoding**: 12 hardcoded parameter defaults
- **Environment Handling**: Dual environment parameters (pEnv and ptaskEnv) with inconsistent casing
- **Missing Lifecycle**: No retention policies for log groups

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires decomposition into modules (IAM, ECS, Glue)
- Complex IAM policy documents need HCL conversion
- Parameter Store references would use aws_ssm_parameter data source

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles and policies
   - ECS task definitions
   - Glue jobs
   - Network components
2. Migrate parameter store references first
3. Implement state management strategy (remote backend + workspaces)
4. Validate with CloudFormation drift detection

