# Repository Assessment: pge-crm-ecm-db-scripts-v2

## 1. Overview
The repository contains AWS CloudFormation templates for CI/CD pipelines focused on database schema management across multiple environments (QA, DEV, TST, PRD). Uses CodePipeline, CodeBuild, IAM roles, and SNS notifications with environment-specific configurations.

## 2. Architecture Summary
- **Core Services**: CodePipeline, CodeBuild, IAM, SNS, KMS
- **Pattern**: Environment-specific CI/CD pipelines for database migrations
- **Key Components**:
  - CodeBuild projects for schema creation and script execution
  - Manual approval gates before deployments
  - SNS notifications for pipeline status
  - SSM parameter store integration for configuration

## 3. Identified Resources
- IAM Roles & Policies (CodeBuild/CodePipeline)
- CodePipeline pipelines (3 stages: Source → Schema Creation → Script Execution)
- CodeBuild projects (Linux containers with VPC connectivity)
- SNS notification rules

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (Resource: "*") in all environments
  - PrivilegedMode enabled in dev/template.yml CodeBuild projects
  - GitHub OAuth tokens stored as plaintext parameters
  - Missing encryption configuration for some pipeline artifacts

- **Reliability**:
  - No retry logic in pipeline stages
  - Hardcoded subnet references in dev environment
  - Missing error handling in buildspecs (not visible in CFN)

- **Compliance**:
  - Inconsistent tagging implementation across environments
  - Missing data retention policies for artifacts
  - No explicit versioning for buildspec files

## 5. Technical Debt
- **Duplication**: Identical pipeline structures repeated across 5 environments
- **Parameter Sprawl**: 20+ parameters per template with inconsistent naming
- **Modularization**: No nested stacks or cross-environment configuration management
- **Hardcoding**: Explicit subnet IDs and service role references

## 6. Terraform Migration Complexity
Moderate to High. Requires:
1. Refactoring IAM policies to least-privilege principles
2. Modularizing environment configurations
3. Converting SSM parameter references to Terraform data sources
4. Handling legacy CodeStarNotifications resources

## 7. Recommended Migration Path
1. **Preparation**:
   - Establish Terraform state management (S3+DynamoDB)
   - Create environment-specific variable files
   - Map SSM parameters to Terraform data sources

2. **Core Migration**:
   - Convert IAM roles/policies first
   - Migrate CodeBuild projects with environment variables
   - Implement CodePipeline stages with proper dependencies

3. **Validation**:
   - Deploy non-production environments first
   - Validate SNS notifications and approval workflows
   - Perform security validation against original CFN

4. **Optimization**:
   - Create Terraform modules for:
     - IAM role/policy pairs
     - CodePipeline stage patterns
     - Environment configuration blocks
   - Implement drift detection

