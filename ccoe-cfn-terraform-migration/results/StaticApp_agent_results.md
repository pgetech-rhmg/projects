# Repository Assessment: StaticApp

## 1. Overview
The repository contains CloudFormation templates for deploying a static application infrastructure with CI/CD pipelines, database management capabilities, and security configurations. Key components include API Gateway, Lambda functions, RDS instances (SQL Server & Aurora MySQL), DMS migration pipelines, CodePipeline/CodeBuild workflows, and WAFv2 protections.

## 2. Architecture Summary
- **Core Pattern**: Serverless application with REST API backed by Lambda functions
- **Database Tier**: SQL Server Enterprise Edition and Aurora MySQL clusters with SecretsManager integration
- **Migration**: DMS replication pipeline for database migrations
- **CI/CD**: CodePipeline/CodeBuild workflows for automated deployments
- **Security**: WAFv2 integration and IAM roles for service permissions
- **Environments**: Parameterized templates for PROD/QA/TEST/DEV environments

## 3. Identified Resources
- **Compute**: Lambda functions (nodejs12.x runtime), DMS replication instances
- **Storage**: RDS (SQL Server & Aurora), S3 buckets
- **Networking**: VPC endpoints, Security Groups, Subnet Groups
- **Security**: IAM Roles, WAFv2 WebACL, SecretsManager
- **Operations**: CloudFormation CustomResources, CodePipeline/CodeBuild
- **Monitoring**: CloudWatch integration (API Gateway only)

## 4. Issues & Risks
- **Security**:
    - Overly permissive IAM policies (`s3:*`, `ec2:*`, `lambda:*` on multiple roles)
    - Hardcoded AWS account IDs in Lambda functions (DeleteStack.yaml, LogSecret.yaml)
    - Missing encryption on S3 buckets (static-pipeline-lambda-api-deploy.yaml)
    - Publicly accessible Lambda function (LogSecret.yaml)
    - Insecure TLS configuration (NODE_TLS_REJECT_UNAUTHORIZED=0)
    - Credentials exposure in DMS endpoint parameters
- **Reliability**:
    - No Lambda dead-letter queues
    - Missing retries in Lambda error handling
    - DMS replication instance not Multi-AZ
- **Compliance**:
    - Deprecated Node.js 12.x runtime
    - Missing data classification tags on many resources
    - Unrestricted database parameter overrides

## 5. Technical Debt
- **Modularization**:
    - Duplicated IAM role definitions across templates
    - Monolithic Lambda functions with multiple responsibilities
    - Inconsistent parameter naming conventions
- **Hardcoding**:
    - AWS region hardcoded in Lambda functions
    - Static IP ranges in WAF configuration
    - Fixed resource names instead of dynamic generation
- **Maintainability**:
    - No environment-specific configurations
    - Missing CloudFormation stack policies
    - Inconsistent use of SSM parameters vs direct references

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- Complex IAM role conversions with mixed managed/inline policies
- DMS service mappings requiring validation
- SAM transform patterns needing refactoring
- Custom resource Lambda functions requiring state

## 7. Recommended Migration Path
Not Observed

