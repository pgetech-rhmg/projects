# Repository Assessment: psps-viz-project-infra

## 1. Overview
The repository implements infrastructure for a visualization application (psps-viz) with CI/CD pipelines, API Gateway, static site hosting, and data ingestion capabilities. It uses SSM parameters for configuration management and Secrets Manager for sensitive values. The architecture includes cross-environment data replication and environment-specific resource provisioning.

## 2. Architecture Summary
- **API Delivery**: API Gateway v2 with regional custom domains backed by ACM certificates
- **Frontend**: Static site hosted in S3 with Amplify, served via CloudFront with WAF integration
- **Data Ingestion**: S3-triggered Lambda for data processing, CodeBuild projects for pipeline automation, and Elasticsearch cluster for data storage
- **Security**: KMS encryption for S3 buckets, Lambda environment variables, and Elasticsearch
- **Environment Management**: Environment-specific configurations using SSM parameters and conditional resources
- **CI/CD**: CodePipeline/CodeBuild integration with GitHub source control

## 3. Identified Resources
- IAM Roles (12+)
- S3 Buckets (5+)
- Lambda Functions (4+)
- CodeBuild Projects (5+)
- API Gateway v2 resources
- CloudFront Distribution
- Amplify App
- Elasticsearch Domain
- Custom Resources (DNS validation, CNAME management)
- SSM Parameters (20+)

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies (e.g., ec2:*, lambda:*, ssm:*)
- **Hardcoded Values**: Explicit AWS account IDs in S3 policies
- **Deprecated Resources**: Elasticsearch 6.8 (EOL August 2022)
- **Missing Lifecycle Policies**: No expiration on pipeline artifacts bucket
- **Inconsistent Logging**: Some buckets missing logging configuration
- **Unvalidated Secrets**: SecretsManager values not using NoEcho

## 5. Technical Debt
- **Parameter Sprawl**: Duplicated SSM parameter references across templates
- **Tight Coupling**: Cross-environment dependencies (prod/qa S3 replication)
- **Poor Modularization**: Single templates handling multiple concerns (pipeline + webhook + domain config)
- **Environment Handling**: Mixed use of SSM parameter resolution syntax
- **Custom Resource Dependencies**: Heavy reliance on third-party custom resources (dflook DNS certificate)

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- Custom resource conversion (DNSCertificate, CNAME)
- Complex IAM policy translations
- Environment-specific logic decomposition
- SSM parameter resolution patterns
- Multi-template dependency management

## 7. Recommended Migration Path
1. **Preparation**:
   - Establish Terraform state management strategy (S3+DynamoDB)
   - Create parameter mapping layer for SSM/Secrets
   - Implement Terraform CI/CD pipeline

2. **Core Infrastructure**:
   - Migrate foundational resources (S3 buckets, KMS keys)
   - Convert static site components (Amplify, CloudFront)
   - Establish base IAM roles with least-privilege policies

3. **API Gateway**:
   - Migrate API Gateway resources using AWS provider
   - Replace custom DNS certificate logic with Terraform AWS ACM validation

