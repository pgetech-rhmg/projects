# Repository Assessment: 50MainApp

## 1. Overview
The repository contains CloudFormation templates implementing CI/CD pipelines for Lambda function deployment and an API Gateway configuration. Key components include:
- GitHub-triggered CodeBuild projects for pre-merge validation
- CodePipeline workflows for automated Lambda layer/function deployments
- API Gateway REST API with Lambda integration for reservation management
- Security roles with varying permission scopes

## 2. Architecture Summary
The solution implements a serverless CI/CD pipeline architecture using AWS-native services:
- **Source Control**: GitHub repositories with webhook triggers
- **Build Automation**: CodeBuild projects with Python build environments
- **Pipeline Orchestration**: CodePipeline workflows with S3 artifact storage
- **Deployment Targets**: Lambda functions (with VPC connectivity) and API Gateway REST APIs
- **Security**: IAM roles with varying levels of privilege escalation

## 3. Identified Resources
- AWS::IAM::Role (4 instances)
- AWS::IAM::ManagedPolicy (1)
- AWS::CodeBuild::Project (3)
- AWS::CodePipeline::Pipeline (2)
- AWS::S3::Bucket (2)
- AWS::Lambda::Function (4)
- AWS::Lambda::LayerVersion (1)
- AWS::Lambda::LayerVersionPermission (1)
- AWS::EC2::SecurityGroup (1)
- AWS::Serverless::Api (1)

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: 
  - rCodeBuildProjectPolicy grants 16 services with wildcard permissions
  - rBuildProjectRole in lambda-layer-pipeline.yml has iam:* and cloudwatch:*
  - rAPIGWLambdaInvokeRole allows lambda:InvokeFunction on *
- **Hardcoded Values**:
  - S3 bucket names (pts6-nonprod-lambda-layers)
  - Lambda layer versioning logic
  - Security group open to 0.0.0.0/0
- **Missing Lifecycle Management**:
  - No S3 bucket versioning/retention policies
  - No Lambda function dead-letter queues
- **Security Best Practices**:
  - GitHub tokens stored as plaintext parameters
  - No VPC endpoints for S3/CloudWatch
  - Missing resource-level permissions in Lambda execution roles

## 5. Technical Debt
- **Tight Coupling**:
  - BuildSpec files embedded in templates
  - Lambda function code inlined
  - Pipeline stages not modularized
- **Parameter Sprawl**:
  - Duplicated tagging parameters across templates
  - Inconsistent parameter naming conventions
- **Environment Management**:
  - Environment values hardcoded in multiple places
  - No clear separation between dev/prod configurations

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- Decomposing monolithic templates into Terraform modules
- Refactoring inline policies into managed policies
- Handling SSM parameter references
- Migrating Serverless Application Model (SAM) constructs
- Managing state dependencies between pipelines and Lambda functions

## 7. Recommended Migration Path
1. **Preparation**:
   - Establish Terraform state management (S3+DynamoDB)
   - Create parameter mapping layer for SSM/CFN parameters

2. **Core Infrastructure**:
   - Migrate S3 buckets as foundational resources
   - Convert IAM roles to Terraform with policy attachments
   - Implement VPC security group as standalone module

3. **CI/CD Components**:
   - Create CodeBuild/Code

