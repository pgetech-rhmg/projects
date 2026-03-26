# Repository Assessment: gis-geomartcloud-wsoc-api-geoincidenthistory

## 1. Overview
This CloudFormation template provisions a serverless API solution for geoincident history management using API Gateway, Lambda, SQS, and IAM. It includes environment-specific configurations, VPC integration, and security controls.

## 2. Architecture Summary
The solution implements:
- Private API Gateway endpoints with VPC endpoint policies
- Two Lambda functions (createjob/jobstatus) with VPC networking
- SQS queue with optional dead-letter queue
- IAM roles with broad permissions for logging, secrets, KMS, and SQS
- CORS configuration for API endpoints
- Environment-specific parameters from SSM Parameter Store

## 3. Identified Resources
- API Gateway REST API (private endpoint)
- Lambda functions (Python 3.9) with VPC configuration
- SQS queue with encryption
- IAM roles with inline policies
- Security group for Lambda networking
- API Gateway authorizer (Lambda-backed)

## 4. Issues & Risks
- **Security**: 
  - IAM roles use wildcard permissions ("s3:*", "kms:*", "sqs:*") violating least privilege
  - Hardcoded Dynatrace credentials in Lambda environment variables
  - API Gateway policy allows public access before VPC condition
  - Missing WAF/Shield integration
- **Reliability**:
  - No DLQ configuration for Lambda failures
  - SQS dead-letter queue only enabled conditionally
- **Operational**:
  - Missing CloudWatch alarms/dashboards
  - No X-Ray tracing configuration for API Gateway

## 5. Technical Debt
- Duplicated parameters (pOrderNumber, pEnv/pTaskEnv)
- Hardcoded region ("us-west-2") in multiple resources
- Inconsistent parameter naming conventions
- Missing resource-level tagging for cost allocation
- No lifecycle policies for old deployments

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for core resources (APIG, Lambda, SQS)
- IAM policy documents would require HCL conversion
- VPC endpoint policies need careful translation
- Parameter Store integration differs between CFN/Terraform
- Would require refactoring of:
  - Intrinsic functions (Fn::Sub, Fn::If)
  - DependsOn relationships
  - Output values

## 7. Recommended Migration Path
1. Establish Terraform state backend (S3+DynamoDB)
2. Migrate parameters to Terraform variables with SSM lookups
3. Convert IAM roles first to validate permissions
4. Migrate SQS queue and dead-letter configuration
5. Implement API Gateway resources with policy documents
6. Migrate Lambda functions and VPC configurations
7. Validate authorizer integration
8. Implement CORS and method configurations

Use Terraform modules for:
- API Gateway + Lambda integration
- IAM roles with policy attachments
- Network configuration (VPC/security groups)

