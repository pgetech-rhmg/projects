# Repository Assessment: ew-data-sync

## 1. Overview
The repository contains two CloudFormation templates implementing a secure API Gateway with mutual TLS authentication backed by a private PKI infrastructure, Lambda functions for business logic, and a CI/CD pipeline using AWS CodePipeline/CodeBuild. The solution emphasizes security through certificate management and API endpoint hardening.

## 2. Architecture Summary
- **Private PKI**: Root and subordinate CAs created with ACM PCA
- **API Security**: Regional API Gateway with mTLS using custom trust store
- **Lambda Functions**: 5x business logic handlers with environment-specific configurations
- **CI/CD**: CodePipeline with GitHub integration and CodeBuild-based deployments
- **Storage**: S3 bucket for trust store artifacts with AES-256 encryption

## 3. Identified Resources
- AWS::ACMPCA::CertificateAuthority (2x)
- AWS::CertificateManager::Certificate (2x)
- AWS::S3::Bucket (2x)
- AWS::IAM::Role (7x)
- AWS::Serverless::Api (1x)
- AWS::Serverless::Function (5x)
- AWS::Serverless::LayerVersion (1x)
- Custom::TrustedStore (1x)
- Custom::DisableDefaultApiEndpoint (1x)
- AWS::CodePipeline::Pipeline (1x)
- AWS::CodeBuild::Project (1x)

## 4. Issues & Risks
- **Security**:
  - LambdaExecutionRole has overly permissive policies (apigateway:*, logs:*)
  - Hardcoded S3 bucket name in LambdaExecutionRole policy
  - Missing WAF association on API Gateway
  - No pipeline failure notifications configured
- **Reliability**:
  - Lambda functions use deprecated nodejs12.x runtime
  - No dead-letter queue configuration for DynamoDB streams
- **Compliance**:
  - S3 bucket policy allows all actions from deploy role
  - Missing resource-level tagging on many components

## 5. Technical Debt
- **Modularization**:
  - Single template combines infrastructure and pipeline definitions
  - No nested stacks or separate modules
- **Hardcoding**:
  - Explicit ARNs and resource names in multiple places
  - Policy documents contain literal resource identifiers
- **Maintainability**:
  - Duplicated IAM policy statements across roles
  - Inconsistent parameter naming conventions

## 6. Terraform Migration Complexity
Moderate complexity due to:
- Custom resource Lambda functions requiring conversion
- SAM transform syntax needing native Terraform equivalents
- Complex IAM policy documents needing HCL translation
- Parameterization differences between CFN and Terraform

## 7. Recommended Migration Path
1. Decouple infrastructure and pipeline into separate Terraform modules
2. Convert core PKI resources first (acmpca_certificate_authority)
3. Migrate S3 buckets with proper state import
4. Translate IAM roles using aws_iam_policy_document data sources
5. Implement Lambda functions with archive_file resources
6. Replace custom resources with Terraform null_resource + local-exec
7. Validate mTLS configuration through API Gateway module

