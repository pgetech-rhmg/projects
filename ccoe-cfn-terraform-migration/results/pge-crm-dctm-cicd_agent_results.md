# Repository Assessment: pge-crm-dctm-cicd

## 1. Overview
The repository contains AWS CloudFormation templates for CI/CD infrastructure supporting CRMIS applications. It includes:
- CodePipeline/CodeBuild configuration for automated builds and deployments
- SSM parameter management for environment variables
- Environment-specific parameter files for QA/PRD

## 2. Architecture Summary
- **CI/CD Pipeline**: GitHub → CodePipeline → CodeBuild (Twistlock scan → DryRun → Deploy)
- **Environments**: QA and PRD configurations
- **Core Services**: CodePipeline, CodeBuild, SSM Parameter Store, SNS, ECR
- **Security**: KMS encryption for artifacts, SecretsManager integration

## 3. Identified Resources
- AWS::CodePipeline::Pipeline
- AWS::CodeBuild::Project (3 per environment)
- AWS::IAM::Role (CodeBuild + CodePipeline)
- AWS::IAM::Policy (overly permissive)
- AWS::SSM::Parameter (environment variables)
- AWS::CodeStarNotifications::NotificationRule (deprecated)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies with `Resource: "*"`
  - Hardcoded ECR URIs in CodeBuild projects
  - Missing S3 bucket policies
  - Deprecated CodeStarNotifications resource
- **Reliability**:
  - No artifact retention policies
  - No pipeline error handling beyond notifications
- **Compliance**:
  - Missing resource tagging
  - No logging configuration for CodeBuild

## 5. Technical Debt
- **Duplication**: Identical pipeline templates in QA/PRD environments
- **Hardcoding**: ECR registry values and S3 bucket names
- **Modularity**: Single monolithic pipeline template
- **Legacy Resources**: CodeStarNotifications (replace with SNS topics)

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean mapping for core services (CodePipeline/CodeBuild/IAM)
- Requires:
  - IAM policy refactoring
  - Environment variable management
  - Module decomposition
  - SSM parameter migration

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state backend (S3+DynamoDB)
   - Establish environment variable strategy

2. **Core Infrastructure**:
   - Migrate SSM parameters first
   - Create IAM roles/policies with least privilege
   - Implement S3 bucket resources with proper policies

3. **CI/CD Components**:
   - Convert CodeBuild projects using `aws_codebuild_project`
   - Migrate CodePipeline with `aws_codepipeline`
   - Replace CodeStarNotifications with SNS topics

4. **Environment Separation**:
   - Create Terraform workspaces for QA/PRD
   - Parameterize environment-specific values

5. **Validation**:
   - Deploy to non-prod environment first
   - Validate pipeline execution and artifact flow

