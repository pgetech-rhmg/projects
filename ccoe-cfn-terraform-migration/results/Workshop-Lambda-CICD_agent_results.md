# Repository Assessment: Workshop-Lambda-CICD

## 1. Overview
The repository contains CloudFormation templates implementing:
- Lambda functions with DynamoDB integration
- CI/CD pipeline using CodePipeline/CodeBuild
- Cross-account IAM roles for Stacker
- EC2 instance provisioning patterns
- Lambda authorizer with KMS encryption

## 2. Architecture Summary
- **Core Pattern**: Serverless application deployment with CI/CD automation
- **Key Services**: Lambda, DynamoDB, CodePipeline, CodeBuild, IAM, S3, KMS
- **Security**: Uses KMS for environment variable encryption and proper S3 bucket policies
- **Deployment**: Implements multi-stage pipeline with validation and deployment phases

## 3. Identified Resources
- IAM Roles/Policies
- DynamoDB Tables
- Lambda Functions
- CodePipeline Pipelines
- CodeBuild Projects
- S3 Buckets
- EC2 Instances (in sample templates)
- KMS Keys

## 4. Issues & Risks
- **Overly Permissive IAM**: Many policies use "*" resources (e.g., rPipelineRole, StackerExecutionRole)
- **Hardcoded Values**: Lambda functions hardcode region 'us-east-1'
- **Deprecated Runtime**: Uses nodejs12.x (reached EOL 2022-12-31)
- **Missing Logging**: Lambda functions lack explicit CloudWatch log group configuration
- **Insecure EC2**: Sample EC2 template uses 0.0.0.0/0 for SSH access

## 5. Technical Debt
- **Inline Code**: Lambda functions use inline ZipFile instead of S3 references
- **Parameter Sprawl**: Many templates use redundant tagging parameters
- **No Environment Separation**: Hardcoded 'DEV' environment tags
- **Tight Coupling**: Pipeline templates directly reference build projects

## 6. Terraform Migration Complexity
- **Moderate Complexity**:
  - Clean 1:1 mappings exist for most resources
  - IAM policy documents require HCL conversion
  - CodePipeline/CodeBuild integration needs verification
  - KMS key handling differs between CFN and Terraform

## 7. Recommended Migration Path
1. **Modularize**: Break into Terraform modules (IAM, Lambda, Pipeline, Network)
2. **State Management**: Use S3 remote state with DynamoDB locking
3. **Phase 1**: Migrate foundational resources (S3 buckets, KMS keys)
4. **Phase 2**: Convert IAM roles/policies with aws_iam_policy_document
5. **Phase 3**: Migrate Lambda functions and DynamoDB
6. **Phase 4**: Implement CI/CD pipeline components
7. **Validation**: Use CloudFormation import to verify parity

