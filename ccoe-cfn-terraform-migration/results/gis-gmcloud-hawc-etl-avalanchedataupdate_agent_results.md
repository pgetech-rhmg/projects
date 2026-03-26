# Repository Assessment: gis-gmcloud-hawc-etl-avalanchedataupdate

## 1. Overview
The repository contains a CloudFormation template for deploying an ETL pipeline that updates avalanche data in a GIS system. Key components include Lambda functions, IAM roles, scheduled events, and integration with EFS, Secrets Manager, and S3.

## 2. Architecture Summary
- **Core Service**: AWS Lambda for ETL processing
- **Trigger**: CloudWatch Events (daily schedule)
- **Data Storage**: EFS (mounted filesystem) and S3 buckets
- **Security**: IAM roles with managed policies and inline permissions
- **Observability**: CloudWatch Logs and X-Ray integration

## 3. Identified Resources
- IAM Roles (2)
- Lambda Function (1)
- CloudWatch Event Rule (1)
- Lambda Permission (1)
- IAM Policy (1)

## 4. Issues & Risks
- **Overly Permissive Policies**: 
  - CloudWatch/SNS/KMS resources use wildcard permissions ("*")
  - RDS Deny rule uses explicit action instead of NotAction
- **Security Gaps**:
  - Missing VPC/security group definitions (referenced but not created)
  - Lambda EFS mount path hardcoded ("/mnt/access")
  - Lambda environment variables use inconsistent casing (pTaskEnv vs pEnv)
- **Configuration Errors**:
  - Duplicate parameters: pBatch and pPsycopg defined twice
  - Lambda VpcConfig uses "Ref" instead of "!Ref" for SubnetIds
  - rCloudwatchEvent references missing rEventruleRole.Arn

## 5. Technical Debt
- **Hardcoded Values**: Lambda timeout (900s), memory (1024MB), and runtime (python3.7)
- **Parameter Sprawl**: 21 parameters with overlapping purposes (pEnv vs pTaskEnv)
- **Tight Coupling**: Lambda function directly references EFS ARN and security group
- **Missing Best Practices**:
  - No resource-level tagging consistency
  - No CloudFormation stack policy
  - No explicit dependency management between resources

## 6. Terraform Migration Complexity
Moderate complexity due to:
- Inline IAM policies requiring conversion
- SSM parameter references needing parameter store integration
- Hardcoded values needing variable extraction
- Missing VPC resources requiring dependency resolution

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state backend configuration
   - Define provider configuration with proper region
   - Extract SSM parameters into Terraform variables

2. **IAM Migration**:
   - Convert IAM roles to aws_iam_role with policy attachments
   - Migrate inline policies to aws_iam_policy resources
   - Replace ARN references with Terraform data sources

3. **Lambda Migration**:
   - Create aws_lambda_function with file archive packaging
   - Migrate environment variables to dynamic blocks
   - Add explicit VPC configuration dependencies

4. **EventBridge Migration**:
   - Convert to aws_cloudwatch_event_rule
   - Use aws_lambda_permission for invocation rights

5. **Validation**:
   - Implement tagging modules
   - Add validation checks for required parameters
   - Verify schedule expressions

