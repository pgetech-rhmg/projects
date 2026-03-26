# Repository Assessment: aws_cfs_somahcsr_api

## 1. Overview
The repository contains CloudFormation templates for deploying a serverless API solution using AWS SAM and CodePipeline. The infrastructure includes a private API Gateway secured with Azure AD authentication, multiple Lambda functions for business logic, and a CI/CD pipeline for automated deployments.

## 2. Architecture Summary
- **Core Pattern**: Serverless microservices architecture
- **Primary Services**:
  - API Gateway (private endpoint with VPC integration)
  - AWS Lambda (Python/Node.js runtimes)
  - IAM (roles and policies)
  - SSM Parameter Store (configuration management)
  - CodePipeline/CodeBuild (CI/CD)
- **Security**: Azure AD OAuth2 authentication
- **Networking**: VPC-enabled Lambda functions with private subnets

## 3. Identified Resources
- 1x API Gateway (private)
- 11x Lambda Functions (Python/Node.js)
- 11x IAM Roles (with managed policies)
- 1x SSM Parameter (Azure auth manifest)
- 1x S3 Bucket (pipeline artifacts)
- 1x CodePipeline
- 1x CodeBuild Project
- 3x IAM Roles (pipeline/build/deploy)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (Resource: "*") in Lambda roles
  - Missing encryption settings for S3 bucket
  - Hardcoded GitHub token in pipeline parameters
  - No WAF integration for API Gateway
- **Configuration**:
  - Duplicate Compliance tag in Globals section
  - Hardcoded region ("us-east-2") in CodeBuild environment
  - Missing dead-letter queues for Lambda error handling
- **Reliability**:
  - No auto-scaling configuration for Lambda concurrency
  - Missing CloudWatch alarms

## 5. Technical Debt
- **Modularity**:
  - Single template contains both infrastructure and pipeline
  - Repeated IAM policy patterns across Lambda roles
- **Hardcoding**:
  - Pipeline bucket name and environment variables
  - Default parameter values in template headers
- **Maintainability**:
  - No resource-level tagging strategy
  - Missing lifecycle policies for old deployments

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean mapping for API Gateway and Lambda resources
- Requires decomposition of:
  - SAM Globals into Terraform modules
  - IAM roles into reusable policy documents
  - Pipeline configuration into Terraform CI/CD constructs
- Challenges with:
  - Azure AD integration syntax differences
  - SSM parameter substitution patterns

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - VPC configuration
   - API Gateway + authorizer
   - Lambda function patterns
   - IAM roles
2. Migrate SSM parameters first
3. Convert API Gateway and core Lambda functions
4. Implement pipeline in Terraform using S3 backend
5. Validate with staging environment
6. Incrementally move remaining Lambda endpoints

