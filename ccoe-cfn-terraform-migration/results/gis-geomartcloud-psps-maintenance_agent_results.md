# Repository Assessment: gis-geomartcloud-psps-maintenance

## 1. Overview
The CloudFormation template provisions scheduled maintenance workflows for a geospatial data platform using AWS Glue. It deploys time-based Glue jobs for monitoring and database maintenance tasks with associated triggers and IAM permissions.

## 2. Architecture Summary
- **Core Services**: AWS Glue (Jobs/Triggers), IAM Roles, S3 (artifact storage), Secrets Manager
- **Pattern**: Scheduled ETL maintenance jobs with environment-specific configurations
- **Environments**: Supports prod/qa/tst/dev through parameterized deployments

## 3. Identified Resources
- 4x AWS::Glue::Job (monitoring + 3 maintenance schedules)
- 4x AWS::Glue::Trigger (cron-based job execution)
- 1x AWS::IAM::Role (Glue execution role with broad permissions)

## 4. Issues & Risks
- **Security**: 
  - IAM Role has overly permissive policies (Resource: "*") across multiple services
  - Missing encryption configuration for S3 buckets
  - No VPC endpoint enforcement for Glue connections
- **Configuration**:
  - pEnv and ptaskEnv parameters are redundant (case sensitivity issue)
  - Hardcoded Python 3.6 dependency in jobs
  - Missing error handling/notification configuration
- **Missing Resources**:
  - No explicit Glue Connection declarations (referenced via !Sub)
  - Database resources not defined in template

## 5. Technical Debt
- **Modularization**: Single template handles all environments and job types
- **Hardcoding**: Python version and package URLs hardcoded
- **Parameter Management**: Duplicated environment parameters with inconsistent casing
- **Lifecycle**: No termination protection or update policies

## 6. Terraform Migration Complexity
Moderate complexity:
- Glue resources map cleanly to Terraform AWS provider
- IAM policy documents require HCL conversion
- SSM parameter references need validation
- Missing resources (Glue Connections) would need discovery

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Glue job/trigger pairs
   - IAM role with policy attachments
   - Environment parameter management
2. Migrate parameters to Terraform variables with validation
3. Convert IAM policies to Terraform JSON syntax
4. Implement incremental migration:
   - First deploy non-critical jobs (monitoring)
   - Validate connections before migrating maintenance jobs
   - Maintain parallel CFN/Terraform until full cutover

