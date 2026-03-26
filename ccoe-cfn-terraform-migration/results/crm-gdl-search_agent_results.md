# Repository Assessment: crm-gdl-search

## 1. Overview
This CloudFormation template provisions CI/CD infrastructure for the GDL Search application using AWS CodePipeline, CodeBuild, ECR, and GitHub integration. It defines a 5-stage pipeline with automated builds, Helm validation, manual approvals, and EKS deployments.

## 2. Architecture Summary
- **CI/CD Pipeline**: 5-stage CodePipeline with GitHub source, CodeBuild-based build/test/deploy stages, and manual approval
- **Build Infrastructure**: 3 CodeBuild projects using VPC-enabled Linux containers
- **Artifact Storage**: S3 bucket with KMS encryption
- **Container Registry**: ECR repository with immutable tagging and scan-on-push
- **Notifications**: SNS integration for pipeline status and approvals

## 3. Identified Resources
- IAM Roles/Policies (CodeBuild, CodePipeline)
- ECR Repository
- CodeBuild Projects (3)
- CodePipeline Pipeline
- SNS Topics (conditional dev environment)
- CodeStarNotifications Rule
- GitHub Webhook

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Uses "*" resources for SecretsManager, SSM, S3, ECR, and KMS actions
- **Hardcoded Subnet References**: Subnet ARNs built with string concatenation
- **Missing Lifecycle Policies**: S3 artifact bucket lacks expiration rules
- **Insecure Environment Variables**: JFrog credentials stored as plaintext environment variables
- **Privilege Escalation**: CodeBuild projects run in privileged mode

## 5. Technical Debt
- **Parameter Sprawl**: 18 parameters with redundant SSM parameter references
- **Tight Coupling**: Hardcoded ECR repository name in buildspec references
- **Environment-Specific Logic**: Dev-only SNS topic handled through conditions
- **Lack of Modularization**: Single monolithic template instead of nested stacks

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (CodePipeline, CodeBuild, ECR)
- IAM policy documents would require HCL conversion
- SSM parameter lookups would use Terraform data sources
- Complex string manipulations would need simplification

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM (roles/policies)
   - ECR repository
   - CodeBuild projects
   - CodePipeline configuration
2. Migrate S3 bucket as standalone resource
3. Use Terraform data sources for SSM/SecretsManager parameters
4. Implement environment separation through workspaces
5. Validate with plan comparisons before deployment

