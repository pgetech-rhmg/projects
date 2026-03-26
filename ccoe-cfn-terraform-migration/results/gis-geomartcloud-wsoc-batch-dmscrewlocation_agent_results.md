# Repository Assessment: gis-geomartcloud-wsoc-batch-dmscrewlocation

## 1. Overview
This CloudFormation repository deploys a data processing pipeline using AWS Lambda, Glue, and IAM roles. It includes two Glue jobs for ETL operations, two Lambda functions for triggering data syncs, and associated security configurations. The infrastructure appears focused on geospatial data management in a regulated environment (Confidential data classification).

## 2. Architecture Summary
- **Core Services**: Lambda, Glue, IAM, VPC, S3, KMS
- **Pattern**: Event-driven ETL pipeline with scheduled Glue jobs
- **Security**: Uses KMS encryption for Lambda, VPC-enabled Lambda functions, and environment-specific parameters
- **Environments**: Supports prod/qa/tst/dev through parameterized configuration

## 3. Identified Resources
- IAM Roles: Lambda execution role, Glue service role
- Lambda Functions: 2x Python 3.7 functions with VPC integration
- Glue Jobs: 2x PythonShell jobs with external dependencies
- Security Groups: 2x EC2 security groups for isolation
- SSM Parameters: 14x references for configuration management

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Both Lambda and Glue roles use Resource: "*" for critical permissions (S3, KMS, EC2, Glue)
- **Hardcoded Security Values**: Lambda encryption uses fixed SSM parameter reference
- **Missing Environment Separation**: Glue jobs reference shared artifact buckets across environments
- **Unrestricted Glue Permissions**: Includes kms:* and iam:* in Glue policy
- **Disabled Resources**: ScheduledJobTrigger commented out without explanation
- **Compliance Gaps**: Compliance tag set to "None" despite Confidential classification

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with inconsistent naming conventions
- **Tight Coupling**: Glue jobs hardcode S3 paths and configuration files
- **No Lifecycle Management**: No retention policies for logs/artifacts
- **Redundant Security Groups**: Two nearly identical groups with minimal differences
- **Inconsistent Environment Handling**: Mixed case in pTaskEnv vs pEnv parameters

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for core resources (Lambda, Glue, IAM)
- SSM parameter references would require AWS provider lookups
- Security group ingress self-references need explicit dependency management
- Would require:
  - Decomposing monolithic IAM policies
  - Refactoring hardcoded S3 paths
  - Establishing proper module structure

## 7. Recommended Migration Path
1. **IAM First**: Convert roles and policies with explicit resource ARNs
2. **Core Services**: Migrate Lambda functions and Glue jobs
3. **Networking**: Implement VPC and security group configurations
4. **State Management**: Use remote state with environment isolation
5. **Incremental Deployment**:
   - First deploy IAM and networking
   - Follow with Lambda functions
   - Finally migrate Glue jobs and triggers

