# Repository Assessment: apptio-cloudability-automation

## 1. Overview
The repository contains CloudFormation templates for deploying Cloudability integration infrastructure including:
- Lambda functions for account verification and metadata management
- Secrets Manager configuration for API credentials
- CI/CD pipeline using CodePipeline and CodeBuild

## 2. Architecture Summary
- **Core Services**: Lambda, IAM, Secrets Manager, KMS, EC2 (security groups), CodePipeline, CodeBuild
- **Pattern**: Event-driven automation with centralized secrets management and CI/CD pipeline
- **Security Model**: Uses KMS-encrypted Secrets Manager for credentials and least-privilege IAM roles

## 3. Identified Resources
- 1 Security Group
- 10 IAM Roles
- 10 Lambda Functions
- 1 KMS Key + Alias
- 2 Secrets Manager Resources
- 1 CodePipeline Pipeline
- 1 CodeBuild Project
- 3 IAM Roles for CI/CD

## 4. Issues & Risks
- **Overly Permissive Security Group**: rCloudabilitynSecurityGroup allows egress to 0.0.0.0/0 on port 443
- **Wildcard Resources**: Multiple IAM policies use Resource: "*" (e.g., KMS permissions)
- **Hardcoded ARNs**: rSecretPolicy references hardcoded AWS account ID 686137062481
- **Missing Logging**: Security group lacks VPC flow logs
- **Long Lambda Timeouts**: 900s timeouts may indicate inefficient operations
- **Deprecated Runtime**: Python 3.12 not yet supported in all regions

## 5. Technical Debt
- **Hardcoded Values**: KMS key policy uses literal ARNs instead of references
- **Tight Coupling**: Lambda functions directly reference other Lambda ARNs
- **Parameter Sprawl**: 15+ SSM parameters with inconsistent naming
- **No Environment Separation**: Single pipeline configuration for all environments
- **Missing Tags**: No resource tagging for cost allocation

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for Lambda, IAM, Secrets Manager
- Security group ingress/egress rules require HCL conversion
- CodePipeline stages would need decomposition into modules
- SSM parameter references need parameter store integration

## 7. Recommended Migration Path
1. Convert core IAM roles and policies to Terraform modules
2. Migrate Secrets Manager resources using aws_secretsmanager_secret
3. Implement Lambda functions with aws_lambda_function
4. Refactor CI/CD pipeline into:
   - codepipeline module
   - codebuild module
   - S3 bucket module
5. Add environment-specific variables and workspaces

