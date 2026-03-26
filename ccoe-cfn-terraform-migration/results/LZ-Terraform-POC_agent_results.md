# Repository Assessment: LZ-Terraform-POC

## 1. Overview
This repository contains CloudFormation templates for a Terraform POC environment that includes:
- AWS Nuke execution pipeline for account cleanup
- CI/CD infrastructure with GitHub integration and CodePipeline/CodeBuild

## 2. Architecture Summary
The solution deploys:
1. CodeBuild project with privileged access to execute Terraform and AWS Nuke
2. CodePipeline with GitHub source stage and CodeBuild build stage
3. IAM roles with broad permissions for pipeline operations

## 3. Identified Resources
- AWS::IAM::Role (3 instances)
- AWS::CodeBuild::Project (2 instances)
- AWS::CodePipeline::Pipeline (1 instance)
- AWS::Logs::LogGroup (implicit via CodeBuild)

## 4. Issues & Risks
- **Critical Security Risk**: CodeBuild project executes AWS Nuke with --no-dry-run enabled
- Excessive IAM permissions: 
  - rPipelineRole has lambda:*, cloudformation:*, kms:*, etc.
  - rBuildProjectRole has Resource: "*" for multiple services
- Hardcoded test account ID (424304752381)
- Missing encryption configurations for S3 buckets
- No VPC configuration for CodeBuild projects

## 5. Technical Debt
- Hardcoded values in buildspec (account IDs, bucket names)
- Wildcard resource policies instead of least privilege
- No environment separation in resource names
- Missing tagging strategy
- Implicit log group creation without retention policy

## 6. Terraform Migration Complexity
Moderate complexity due to:
- IAM policy conversion requiring HCL syntax
- BuildSpec translation to Terraform buildspec blocks
- Parameter management differences between CFN and Terraform
- Need to decompose monolithic pipeline into modules

## 7. Recommended Migration Path
1. Convert IAM roles first using aws_iam_role resources
2. Migrate CodeBuild projects with aws_codebuild_project
3. Refactor CodePipeline using aws_codepipeline
4. Replace parameters with Terraform variables
5. Modularize into:
   - IAM module
   - CodeBuild module
   - Pipeline orchestration module

