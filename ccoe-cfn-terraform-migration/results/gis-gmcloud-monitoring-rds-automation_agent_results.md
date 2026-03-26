# Repository Assessment: gis-gmcloud-monitoring-rds-automation

## 1. Overview
The repository contains CloudFormation infrastructure for automated RDS monitoring in a GIS environment. It deploys a scheduled Lambda function with broad AWS service access for database maintenance tasks, using environment-specific configurations and security controls.

## 2. Architecture Summary
- **Core Service**: AWS Lambda function scheduled via CloudWatch Events
- **Security**: IAM roles with managed/inline policies for Lambda and EventBridge
- **Networking**: VPC-enabled Lambda with dedicated security group
- **Environment**: Parameter-driven configuration using SSM Parameter Store
- **Key Patterns**: Event-driven automation with centralized logging permissions

## 3. Identified Resources
- IAM Roles: Lambda execution role + EventBridge invocation role
- Lambda Function: Python 3.10 runtime with VPC configuration
- Security Group: For Lambda network isolation
- CloudWatch Event Rule: Daily scheduled trigger
- IAM Policy: For EventBridge Lambda invocation permissions

## 4. Issues & Risks
- **Overly Permissive IAM**: Lambda role has 11 services with full wildcard permissions (e.g., ec2:*, s3:*)
- **Missing Dependencies**: rCloudwatchEvent references undefined rEventruleRole
- **Hardcoded Values**: Lambda schedule uses PST timezone without conversion
- **Security Gap**: No explicit VPC endpoint configurations for service access
- **Compliance Risk**: Uses AmazonRDSFullAccess managed policy

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with overlapping environment values
- **Inline Policies**: Lambda role contains 10 inline statements (>250 lines total)
- **Tagging Inconsistency**: pOrderNumber uses numeric default but string type
- **Hardcoded ARNs**: Lambda layer ARN uses us-west-2 region

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for all resources
- Requires decomposition of inline policies into modules
- SSM parameter references need conversion to Terraform data sources
- Dependency ordering would need explicit management

## 7. Recommended Migration Path
1. Convert core resources (VPC, IAM, Lambda) to Terraform modules
2. Migrate SSM parameters to terraform.tfvars
3. Decompose inline policies into policy-as-code modules
4. Validate schedule expression timezone handling
5. Implement gradual rollout:
   - First deploy IAM roles
   - Then Lambda + security group
   - Finally CloudWatch events

