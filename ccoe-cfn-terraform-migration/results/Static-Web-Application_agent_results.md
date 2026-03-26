# Repository Assessment: Static-Web-Application

## 1. Overview
The repository contains CloudFormation templates for deploying a static web application with CI/CD pipelines, database infrastructure (SQL Server and Aurora MySQL), Lambda functions for database operations, API Gateway integration, and DMS-based database migration. Key components include:
- Angular application deployment pipeline
- RDS database provisioning (SQL Server and Aurora)
- Lambda functions for CRUD operations and database migration
- API Gateway with WAFv2 protection
- Cross-account IAM roles for DMS

## 2. Architecture Summary
The solution implements a multi-tier architecture with:
- **Frontend**: Static web app deployed via CodePipeline/CodeBuild
- **Backend**: Lambda functions (Node.js 12.x) with VPC connectivity
- **Database**: SQL Server RDS (enterprise edition) and Aurora MySQL cluster
- **Security**: Secrets Manager integration, WAFv2 IP whitelisting
- **Migration**: DMS replication tasks with custom Lambda helpers
- **Observability**: API Gateway CloudWatch integration

## 3. Identified Resources
- **Core Services**: S3, Lambda, API Gateway, RDS, DMS, SecretsManager, WAFv2
- **Support Services**: IAM, CodePipeline, CodeBuild, SSM Parameter Store
- **Networking**: VPC endpoints, Security Groups, Subnet Groups
- **Total Resource Types**: 16 distinct AWS resource types

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (`s3:*`, `lambda:*`, `ec2:*` on multiple roles)
  - Hard-coded credentials in Lambda inline code (`region="us-west-2"`)
  - Missing encryption for S3 pipeline buckets
  - Publicly accessible Lambda functions (LogSecret)
  - Insecure TLS configuration (`NODE_TLS_REJECT_UNAUTHORIZED=0`)
  - DMS role allows all Lambda/Events/CloudFormation actions

- **Configuration**:
  - Lambda functions use deprecated Node.js 12.x runtime
  - SQL Server RDS uses legacy parameter group family (sqlserver-ee)
  - Aurora MySQL has duplicate AutoMinorVersionUpgrade properties
  - Missing error handling in Lambda custom resources
  - Hard-coded VPC/subnet references in LogSecret Lambda

- **Reliability**:
  - No retries in Lambda S3 bucket deletion logic
  - Missing dead-letter queues for Lambda functions
  - Aurora MySQL replica creation has inconsistent parameter group family

## 5. Technical Debt
- **Modularization**:
  - Duplicated IAM policy documents across templates
  - Mixed database-specific and common Lambda functions
  - No nested stacks or template reuse

- **Hardcoding**:
  - Explicit AWS account IDs in ARN references
  - Fixed region references ("us-west-2")
  - Static IP ranges in WAF configuration
  - Fixed Lambda timeout values (30 seconds)

- **Maintainability**:
  - Inconsistent parameter naming conventions
  - Missing resource-level tagging
  - No lifecycle policies for S3 buckets
  - Lambda functions contain business logic in inline code

## 6. Terraform Migration Complexity
Not Observed

## 7. Recommended Migration Path
Not Observed

