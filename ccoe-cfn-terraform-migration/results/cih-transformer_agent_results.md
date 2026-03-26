# Repository Assessment: cih-transformer

## 1. Overview
The CloudFormation template establishes a CI/CD pipeline using AWS CodeBuild with supporting IAM roles and SNS notifications. It references VPC configuration from SSM Parameter Store and deploys Helm charts to EKS clusters.

## 2. Architecture Summary
- **CI/CD Engine**: AWS CodeBuild with container-based builds
- **Artifact Storage**: S3 bucket for build artifacts
- **Security**: IAM roles with broad permissions for CodeBuild
- **Networking**: VPC-enabled CodeBuild projects in private subnets
- **Notifications**: EventBridge rule for build status changes

## 3. Identified Resources
- 2x IAM Roles (CodeBuild service + trigger)
- 1x CodeBuild Project
- 1x EventBridge Rule

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (ec2:*, logs:*) violate least privilege
  - Hardcoded KMS key ARN (us-west-2:720720378559) creates region dependency
  - Missing S3 bucket encryption configuration
  - CodeBuild runs in privileged mode
- **Configuration**:
  - EventBridge rule triggers on SUCCEEDED status (unnecessary noise)
  - Missing VPC endpoint configurations for S3/KMS
  - No resource tagging implemented

## 5. Technical Debt
- **Modularization**: Single template combines IAM, compute, and networking
- **Hardcoding**: KMS key ARN and account ID (720720378559)
- **Environment Handling**: Uses single artifact bucket across environments
- **Lifecycle Management**: No termination protection or update policies

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- IAM policy documents require HCL conversion
- EventBridge syntax differs slightly
- SSM parameter references need translation

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles
   - CodeBuild project
   - EventBridge rules
2. Migrate parameters to Terraform variables
3. Convert SSM parameter references to data sources
4. Implement environment-specific backends
5. Validate with `terraform plan` before deployment

