# Repository Assessment: gis-gmcloud-monitoring-s3-automation

## 1. Overview
The repository contains CloudFormation infrastructure for S3 monitoring automation using AWS Lambda, EventBridge, and IAM roles. Targets daily execution of Lambda functions for S3 operations with extensive logging and notification capabilities.

## 2. Architecture Summary
- **Core Services**: Lambda, IAM, EventBridge, CloudWatch Logs
- **Pattern**: Scheduled Lambda execution via EventBridge for S3 automation
- **Security**: Uses KMS encryption for Lambda environment variables
- **Environments**: Supports prod/qa/tst/dev through parameters

## 3. Identified Resources
- IAM Roles (2): Lambda execution role + EventBridge invocation role
- Lambda Function: Python 3.10 runtime with VPC configuration
- Security Group: For Lambda VPC isolation
- EventBridge Rule: Daily cron schedule (PST timezone)
- IAM Policies: Custom policies attached to roles

## 4. Issues & Risks
- **Overly Permissive IAM**: Lambda role has 11 services with full * permissions
- **Hardcoded Email**: pNotify parameter contains plaintext email
- **Missing VPC Endpoints**: Lambda may require VPC endpoints for service access
- **Excessive RDS Permissions**: Includes AmazonRDSFullAccess policy
- **Resource Exposure**: S3 policy uses s3:* wildcard
- **No Dead Letter Queue**: Lambda lacks error handling configuration

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with overlapping environment variables
- **Tight Coupling**: Lambda depends directly on multiple AWS services
- **No Modularization**: Single monolithic template structure
- **Hardcoded Values**: Lambda timeout (900s) and memory (1024MB) not parameterized

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for all resources
- Requires decomposition of inline policies
- Parameter handling would need refactoring
- EventBridge cron syntax differs slightly between CFN/Terraform

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles and policies
   - Lambda function configuration
   - VPC security group
   - EventBridge scheduling
2. Migrate parameters to Terraform variables with validation
3. Replace !Sub/!Ref with Terraform expressions
4. Implement gradual rollout:
   - First deploy IAM roles
   - Then Lambda + VPC resources
   - Finally EventBridge integration

