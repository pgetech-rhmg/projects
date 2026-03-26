# Repository Assessment: pge-drc-eks

## 1. Overview
This CloudFormation template establishes CI/CD infrastructure for EKS deployments using AWS CodePipeline, CodeBuild, and GitHub integration. It defines IAM roles with broad permissions, S3 artifact storage, and pipeline stages for source control and build processes.

## 2. Architecture Summary
The solution implements:
- GitHub-triggered CI/CD pipeline
- CodeBuild for build/test automation
- S3 artifact storage
- Overly permissive IAM roles for pipeline components

## 3. Identified Resources
- 4x IAM Roles (CodeBuild, CodePipeline, CloudFormation)
- 3x IAM Policies with wildcard permissions
- 1x S3 Bucket (versioned)
- 1x CodeBuild Project
- 1x CodePipeline Pipeline
- 1x GitHub Webhook integration

## 4. Issues & Risks
- **Critical Security Risk**: All IAM policies use "Resource: '*'" with admin-level permissions (iam:*, ec2:*, s3:*, etc.)
- **Credential Exposure**: GitHub OAuth token stored as plaintext parameter
- **Missing Encryption**: S3 bucket lacks encryption configuration
- **No Logging**: No CloudTrail/CloudWatch integration
- **Hardcoded Values**: ComputeType and AMI versions hardcoded

## 5. Technical Debt
- **Tight Coupling**: Pipeline stages directly reference resources instead of parameters
- **Poor Modularity**: Single template contains all resources
- **No Environment Separation**: No dev/prod staging
- **Missing Lifecycle Policies**: S3 bucket lacks expiration rules

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- IAM policy documents would require HCL conversion
- GitHub webhook authentication would need secrets management
- No intrinsic CFN features requiring major refactor

## 7. Recommended Migration Path
1. Decompose into Terraform modules:
   - IAM (roles + policies)
   - S3 bucket
   - CodeBuild
   - CodePipeline
2. Parameterize all environment-specific values
3. Migrate IAM first to validate permissions
4. Implement Terraform backend configuration
5. Add missing encryption/logging configurations during migration

