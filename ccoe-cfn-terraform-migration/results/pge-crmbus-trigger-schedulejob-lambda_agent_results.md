# Repository Assessment: pge-crmbus-trigger-schedulejob-lambda

## 1. Overview
The repository contains AWS CloudFormation templates for deploying a scheduled Lambda function and CI/CD pipeline infrastructure. The Lambda function triggers a scheduled job every 5 minutes, interacts with S3 and SNS, and uses Secrets Manager for database credentials. The CI/CD pipeline uses CodePipeline and CodeBuild for automated builds and deployments from GitHub.

## 2. Architecture Summary
- **Event-Driven Scheduling**: CloudWatch Events triggers Lambda every 5 minutes
- **Lambda Execution**: Java 11 Lambda function running in VPC with access to S3, KMS, Secrets Manager, and SNS
- **Notification System**: SNS topic with email subscription for failure notifications
- **CI/CD Pipeline**: 
  - CodePipeline orchestrates source/build/deploy stages
  - CodeBuild projects handle Maven builds and EKS deployments
  - GitHub integration with webhook triggers

## 3. Identified Resources
- **Lambda**: 1 function with execution role and 3 inline policies
- **IAM**: 2 roles (Lambda + CodePipeline) with 4 managed policies and 3 inline policies
- **SNS**: 1 encrypted topic with email subscription
- **CloudWatch**: 1 scheduled event rule
- **CodePipeline**: 1 pipeline with 4 stages
- **CodeBuild**: 3 build projects (app build, deploy, post-deploy test)
- **Secrets Manager**: Referenced for database credentials
- **SSM Parameters**: 14 parameters for configuration

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (e.g., S3:*, SSM:*, KMS:*)
  - Missing S3 bucket policies
  - Hardcoded SNS topic ARN in policy
  - Public SNS topic policy allows root/ECM_Ops access
- **Reliability**:
  - No dead-letter queue for SNS failures
  - Missing CloudWatch Logs configuration
  - No VPC flow logs
- **Operational**:
  - Duplicate files (bin/codepipeline vs codepipeline)
  - Hardcoded values in Lambda environment variables
  - Missing deployment validation stage

## 5. Technical Debt
- **Modularization**: Single template for both Lambda and pipeline
- **Parameterization**: 
  - Hardcoded S3 bucket ARNs
  - Missing environment-specific parameters
  - Duplicated parameter definitions
- **Maintainability**:
  - Inconsistent resource naming conventions
  - Missing resource-level tagging
  - No lifecycle policies

## 6. Terraform Migration Complexity
Moderate complexity:
- **Clean Mappings**: Lambda, SNS, IAM roles/policies, and CodePipeline map well
- **Refactoring Needed**:
  - Decompose monolithic templates
  - Convert inline policies to managed
  - Parameterize hardcoded values
  - Add missing resources (logging, monitoring)

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state backend (S3+DynamoDB)
   - Establish module structure (lambda, pipeline, iam)

