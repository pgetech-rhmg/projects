# Repository Assessment: csp-cdp-eks-shutdown-function

## 1. Overview
The repository contains CloudFormation templates for deploying a CI/CD pipeline (CodePipeline/CodeBuild) that builds and deploys a Python Lambda function with VPC connectivity. The solution includes:
- Lambda function with environment variables and reserved concurrency
- CodeBuild projects for build/deploy orchestration
- S3 artifact storage with KMS encryption
- IAM roles with broad permissions

## 2. Architecture Summary
- **CI/CD Pipeline**: GitHub → CodePipeline → CodeBuild → S3 → CloudFormation StackSet
- **Lambda**: Python 3.8 runtime with VPC access to private subnets
- **Security**: Uses KMS for Lambda encryption and S3 bucket encryption
- **Networking**: Lambda deployed in 3 private subnets with dedicated security group

## 3. Identified Resources
- AWS::IAM::Role (4 instances)
- AWS::CodeBuild::Project (3 instances)
- AWS::S3::Bucket (1)
- AWS::S3::BucketPolicy (1)
- AWS::CodePipeline::Pipeline (1)
- AWS::Serverless::Function (1)
- AWS::EC2::SecurityGroup (1)

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: 
  - rCodeBuildServiceRole and rCodeBuildTriggerServiceRole have "Resource: '*'" for multiple services
  - Lambda execution role uses 10+ managed policies including full access to Kinesis/RDS/SQS/DynamoDB
  - KMS policy allows all actions on all resources
- **Hardcoded Values**:
  - Lambda timeout defaults to 300s (5m)
  - Lambda memory defaults to 128MB
  - CodeBuild uses fixed compute type (BUILD_GENERAL1_SMALL)
- **Missing Security Best Practices**:
  - No VPC flow logs enabled
  - Lambda environment variables contain plaintext values
  - S3 bucket policy allows all S3 actions from pipeline roles
- **Deprecated Patterns**:
  - Uses PrivilegedMode: true in CodeBuild
  - Lambda uses python3.8 runtime (end-of-support 2024-10-14)

## 5. Technical Debt
- **Tight Coupling**: 
  - Lambda configuration hardcoded in multiple templates
  - CodeBuild buildspec references fixed artifact names
- **Parameter Sprawl**: 
  - Duplicated parameters across templates (pEnv, pProjectName, etc.)
- **Missing Modularization**:
  - Single monolithic pipeline template
  - No nested stacks or separate configuration files

## 6. Terraform Migration Complexity
Moderate complexity:
- **Clean Mappings**: S3, IAM, Lambda, CodeBuild/Pipeline have direct Terraform equivalents
- **Refactoring Needed**:
  - Decompose IAM policies into least-privilege statements
  - Convert SAM transform syntax to native Lambda resources
  - Modularize into Terraform modules (networking, compute, pipeline)
- **Challenges**:
  - Serverless Application Model (SAM) transform requires manual conversion
  - Complex buildspec.yml logic would need HCL translation

## 7. Recommended Migration Path
Not Observed

