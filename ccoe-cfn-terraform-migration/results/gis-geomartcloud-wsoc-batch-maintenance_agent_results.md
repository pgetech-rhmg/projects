# Repository Assessment: gis-geomartcloud-wsoc-batch-maintenance

## 1. Overview
This CloudFormation template provisions AWS Glue ETL infrastructure with batch job scheduling. It creates IAM roles, Glue jobs, triggers, and security groups while leveraging SSM Parameter Store for configuration management.

## 2. Architecture Summary
- **Core Services**: AWS Glue (Jobs/Triggers), IAM Roles, EC2 Security Groups
- **Pattern**: Batch ETL pipeline with scheduled execution
- **Environment Handling**: Uses SSM parameters and environment-specific S3 buckets
- **Security**: SecurityConfiguration reference for Glue encryption

## 3. Identified Resources
- 1x IAM Role (Glue execution role)
- 2x Glue Jobs (PythonShell jobs)
- 2x Glue Triggers (Scheduled cron jobs)
- 1x EC2 Security Group (Self-referencing ingress)

## 4. Issues & Risks
- **Overly Permissive IAM Role**: Uses 10+ wildcard permissions including s3:*, ecs:*, iam:*
- **Hardcoded Email**: Uses static email (s6at@pge.com) in tags
- **Missing Resource Constraints**: Many policies grant access to all resources ("*")
- **Unused Parameters**: Duplicated pEnv/pTaskEnv parameters
- **Disabled Resources**: Commented-out critical components (GlueConnection, SecretsManager)

## 5. Technical Debt
- **Parameter Sprawl**: 17 parameters with overlapping purposes
- **Tight Coupling**: Glue jobs reference specific S3 paths
- **No Lifecycle Management**: No termination policies
- **Inconsistent Naming**: Mixed casing in parameter descriptions

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires refactoring of:
  - IAM policy documents
  - Complex string substitutions
  - Disabled resource handling

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles
   - Glue jobs/triggers
   - Security groups
2. Migrate parameters to Terraform variables with validation
3. Implement resource-specific policies instead of wildcards
4. Use Terraform data sources for SSM parameters
5. Validate with `terraform plan` before deployment

