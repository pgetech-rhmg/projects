# Repository Assessment: pge-crm-cicd-testautomation

## 1. Overview
This CloudFormation template establishes a CI/CD pipeline for automated testing infrastructure using AWS CodePipeline, CodeBuild, and GitHub integration. It includes IAM roles, S3 artifact storage, and SNS notifications.

## 2. Architecture Summary
- **CI/CD Pipeline**: CodePipeline orchestrates source (GitHub) and build (CodeBuild) stages
- **Build Environment**: CodeBuild runs in a VPC with 3 private subnets
- **Security**: Uses SSM parameters for secrets and KMS encryption
- **Notifications**: SNS integration for pipeline status

## 3. Identified Resources
- IAM Roles/Policies (CodeBuild + CodePipeline)
- CodeBuild Project
- CodePipeline Pipeline
- CodeStarNotifications Rule
- GitHub Webhook

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Both roles have `s3:*`, `ec2:*`, `cloudformation:*` and other wildcard permissions
- **Hardcoded Security Groups**: pEKSClusterSecurityGroup uses literal value instead of SSM parameter
- **Missing Environment Separation**: Defaults to "/general/environment" parameter
- **No Lifecycle Policies**: S3 artifact bucket lacks expiration rules
- **CodeBuild Timeout**: 10-minute timeout may be insufficient for complex builds

## 5. Technical Debt
- **Parameter Sprawl**: 18 parameters with inconsistent SSM usage
- **Hardcoded Values**: Security group IDs and GitHub owner pattern
- **No Modularization**: Single monolithic template
- **Missing Resource Prefixes**: Resource names don't follow consistent naming convention

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires refactoring of:
  - IAM policies to use Terraform's aws_iam_policy_document
  - SSM parameter references
  - Complex string joins
- Security group handling needs normalization

## 7. Recommended Migration Path
1. **IAM Stage**: Migrate roles/policies first with explicit actions
2. **Core Pipeline**: Convert CodeBuild and CodePipeline resources
3. **Notifications**: Implement CodeStarNotifications and SNS integration
4. **Validation**: Use `terraform plan` to verify against existing stack
5. **Incremental Deployment**: Deploy non-critical resources first

