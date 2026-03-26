# Repository Assessment: gis-ec2instance-automation

## 1. Overview
The repository contains a CloudFormation template for deploying an automated EC2 instance management solution using AWS Lambda and CloudWatch Events. The infrastructure includes IAM roles, security groups, scheduled execution, and VPC integration for network isolation.

## 2. Architecture Summary
The solution uses:
- Lambda function for automation tasks
- IAM roles with broad permissions
- CloudWatch Events for scheduled execution
- Security group for network isolation
- SSM Parameter Store for configuration
- KMS encryption for Lambda environment variables

## 3. Identified Resources
- IAM::Role (rLambdaFunctionRole, rEventruleRole)
- IAM::Policy (RolePolicies)
- Lambda::Function (rInvokeLambdaFunction)
- EC2::SecurityGroup (rLambdaSecurityGroup)
- Events::Rule (rCloudwatchEvent)
- Lambda::Permission (PermissionForEventsToInvokeLambda)

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Uses 11 wildcard permissions including ec2:*, s3:*, cloudwatch:*
- **Hardcoded Security Group Name**: Risk of name collisions across environments
- **Missing VPC Endpoints**: Lambda may require VPC endpoints for AWS service access
- **Deprecated Lambda Runtime**: Python 3.7 reached EOL June 2023
- **Public S3 Access**: S3 permissions don't restrict to specific buckets
- **No Logging Configuration**: Lambda missing explicit log group configuration

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with overlapping purposes (pEnv vs pTaskEnv)
- **Hardcoded Values**: Security group name and cron schedule
- **No Environment Separation**: Single template for all environments
- **Inline Policies**: Should use managed policies for better management
- **Missing Dead Letter Queue**: For Lambda error handling

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires:
  - Decomposing inline policies
  - Refactoring parameter handling
  - Adding missing VPC endpoint configurations
  - Modularizing into Terraform modules

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles
   - Lambda function
   - Security group
   - CloudWatch rules
2. Migrate parameters to Terraform variables with validation
3. Replace inline policies with AWS-managed policies where possible
4. Add explicit logging configuration
5. Implement environment-specific configurations
6. Validate with `terraform plan` before deployment

