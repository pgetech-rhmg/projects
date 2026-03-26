# Repository Assessment: csp-cdp-rds-shutdown-function

## 1. Overview
The repository implements a CI/CD pipeline for deploying a Python Lambda function with VPC access that handles database shutdown operations. It uses AWS CodePipeline, CodeBuild, S3, IAM, KMS, and Lambda with VPC integration. The solution includes environment-specific configurations and security controls but contains several anti-patterns and security risks.

## 2. Architecture Summary
- **CI/CD Pipeline**: GitHub → CodePipeline → CodeBuild → S3 → CloudFormation StackSet
- **Lambda Function**: Python 3.8 runtime with VPC access to private subnets
- **Security**: Uses KMS encryption, managed IAM policies, and environment tagging
- **Networking**: Lambda deployed in 3 private subnets with dedicated security group
- **Environments**: Separate dev/prod configurations with parameter overrides

## 3. Identified Resources
- 2x IAM Roles (CodeBuild + CodePipeline)
- 1x S3 Bucket (artifact storage)
- 1x CodePipeline Pipeline
- 2x CodeBuild Projects
- 1x Lambda Function
- 1x Security Group (Lambda VPC access)
- 1x KMS Key Reference (Lambda encryption)

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Both CodeBuild and Lambda roles use "*" resources for critical actions like s3:*, iam:*, kms:*
- **Hardcoded KMS Key**: Explicit ARN reference in Lambda KMS policy creates environment coupling
- **Missing VPC Flow Logs**: Lambda VPC configuration lacks flow logging
- **Privileged CodeBuild**: PrivilegedMode=true in CodeBuild project
- **Environment Parameter Mismatch**: Lambda template defaults to prod while pipeline defaults to dev
- **Insecure Lambda Permissions**: Combines read/write policies (AmazonRDSReadOnlyAccess + AmazonDynamoDBFullAccess)

## 5. Technical Debt
- **Parameter Sprawl**: Duplicated parameters across templates (pEnv, pPrivateSubnets)
- **Tight Resource Coupling**: Lambda depends directly on VPC configuration
- **No Lifecycle Policies**: S3 bucket uses DeletionPolicy:Retain without expiration
- **Inconsistent Tagging**: Lambda uses different tag format than other resources

## 6. Terraform Migration Complexity
Moderate complexity due to:
- Serverless transform requiring AWS provider shims
- Complex IAM policy documents needing HCL conversion
- Environment-specific parameters requiring refactoring
- VPC dependencies requiring explicit ordering

## 7. Recommended Migration Path
1. Convert S3 bucket and core networking resources first
2. Migrate IAM roles using aws_iam_policy_document
3. Implement Lambda with aws_lambda_function and VPC config
4. Refactor CodeBuild/CodePipeline using modules
5. Maintain parameter hierarchy with Terraform variables
6. Validate with terraform plan before deployment

