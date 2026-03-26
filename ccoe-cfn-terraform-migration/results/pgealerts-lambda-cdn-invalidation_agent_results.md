# Repository Assessment: pgealerts-lambda-cdn-invalidation

## 1. Overview
This repository contains a CloudFormation template implementing CI/CD infrastructure for Lambda functions using SAM, CodePipeline, CodeBuild, and GitHub integration. The solution includes API Gateway endpoints, S3 artifact storage, and IAM roles with broad permissions.

## 2. Architecture Summary
- **CI/CD Pipeline**: GitHub → CodePipeline → CodeBuild → Lambda deployment
- **Compute**: Lambda functions (Node.js 12.x) with API Gateway triggers
- **Storage**: S3 buckets for pipeline artifacts and build outputs
- **Security**: IAM roles with wildcard permissions for CodeBuild/CodePipeline

## 3. Identified Resources
- 2x S3 Buckets (TestCfnLambdaPipelineS3, TestCfnLambdaOutputS3)
- 2x Lambda Functions (TestCfnLambdaAuthApi, TestCfnLambdaCallbackApi)
- 1x CodeBuild Project (TestCfnLambdaBuild)
- 1x CodePipeline (TestCfnLambdaPipeline)
- 1x CodePipeline Webhook (TestCfnLambdaPipelineWebhook)
- 3x IAM Roles (FunctionServiceRole, BuildServiceRole, CodePipelineServiceRole)

## 4. Issues & Risks
- **Security**: 
  - IAM roles use "Resource: *" for Lambda, S3, and CodePipeline permissions
  - CodeBuild has lambda:* permissions
  - Missing encryption configuration on S3 buckets
  - Hardcoded GitHub token reference pattern
- **Reliability**:
  - No error handling in Lambda inline code
  - No deployment validation in CodeBuild
- **Compliance**:
  - Uses deprecated Node.js 12.x runtime
  - Missing environment tagging

## 5. Technical Debt
- Hardcoded "master" branch default
- Inline Lambda code instead of external modules
- No environment-specific parameters
- No lifecycle policies on S3 buckets
- CodePipeline has 12+ AWS service wildcard permissions

## 6. Terraform Migration Complexity
Moderate complexity:
- SAM transforms require conversion to native Terraform resources
- IAM policy documents need HCL formatting
- CodeBuild buildspec would use heredoc syntax
- Would require:
  - 1x AWS provider configuration
  - 5x Terraform modules (IAM, S3, Lambda, APIGW, CI/CD)
  - Parameterization of environment variables

## 7. Recommended Migration Path
1. Create Terraform state backend configuration
2. Migrate S3 buckets with proper encryption
3. Convert IAM roles with least-privilege policies
4. Implement Lambda functions as Terraform modules
5. Rebuild CodePipeline/CodeBuild with Terraform resources
6. Validate deployments before cutting over

