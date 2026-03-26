# Repository Assessment: emergency-website-aws-cfn-ami

## 1. Overview
The repository implements an automated Golden AMI Factory for Linux, Windows, and EKS environments using AWS CloudFormation. It creates secure AMIs through CodePipeline workflows that include source control integration, EC2 instance provisioning, security assessments, manual approvals, and AMI sharing across accounts.

## 2. Architecture Summary
- **Core Infrastructure**: Shared KMS keys, IAM roles, SSM parameters, and Lambda functions for AMI creation/sharing
- **AMI Pipelines**: Separate CodePipeline workflows for Linux, Windows, and EKS AMIs
- **Security**: Uses AWS Inspector for vulnerability scanning, SSM Parameter Store for secrets, and IAM roles with least privilege
- **AMI Distribution**: DynamoDB table tracks target accounts, and Lambda functions handle cross-account sharing

## 3. Identified Resources
- IAM Roles (15+)
- Lambda Functions (8+)
- CodePipeline Pipelines (3)
- DynamoDB Table (1)
- SSM Parameters (15+)
- KMS Keys (2)
- Secrets Manager Secrets (3+)
- Inspector Assessment Templates (3)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (ec2:*, s3:*) in CodePipelineRole
  - Hardcoded S3 bucket names ("pge-hosting-windows")
  - Missing encryption at rest for DynamoDB table
  - Public exposure risk if EC2 instances have public IPs (not shown)
- **Reliability**:
  - Single-region deployment (us-west-2 hardcoded)
  - No rollback configuration in CodeDeploy
- **Maintainability**:
  - Duplicated pipeline configurations between OS types
  - Hardcoded environment values ("prod"/"dev")
  - Missing versioning on Lambda functions

## 5. Technical Debt
- **Modularity**:
  - Core stack contains OS-specific resources (PAPM SSH key)
  - Pipeline templates mix infrastructure and application logic
- **Parameterization**:
  - Many hardcoded values in pipeline stages
  - Inconsistent parameter naming conventions
- **State Management**:
  - SSM parameters used as pipeline state store
  - No lifecycle management for old AMIs

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- Converting SSM parameter lookups to Terraform data sources
- Refactoring IAM roles with complex inline policies
- Migrating Lambda functions with environment variables
- Handling cross-stack references between core and pipeline stacks

## 7. Recommended Migration Path
1. **Core Infrastructure**:
   - Migrate KMS/SSM/Secrets first
   - Create Terraform modules for IAM roles
2. **AMI Pipelines**:
   - Convert Linux pipeline first as template
   - Parameterize all environment-specific values
   - Use Terraform null_resource for manual approval steps
3. **Lambda Functions**:
   - Use zipfile() for inline code
   - Migrate environment variables to variables.tf
4. **Validation**:
   - Deploy to non-prod environment first
   - Validate AMI creation and sharing workflows

