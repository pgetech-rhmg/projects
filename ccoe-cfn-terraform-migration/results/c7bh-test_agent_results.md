# Repository Assessment: c7bh-test

## 1. Overview
The repository contains CloudFormation templates for deploying an Outage History Tracking (OHT) environment with CI/CD infrastructure. Key components include:
- S3 buckets for storage and archiving
- DynamoDB table for outage data
- Lambda function for CSV-to-DynamoDB processing
- CodePipeline/CodeBuild for automated deployments
- Environment-specific configurations

## 2. Architecture Summary
The solution implements a data ingestion pipeline using S3 event notifications to trigger Lambda processing into DynamoDB. CI/CD pipelines manage infrastructure deployments across multiple environments (Dev/Test/Prod). Security controls include KMS encryption, restricted bucket policies, and least-privilege IAM roles.

## 3. Identified Resources
- **S3**: 4 buckets (primary, archive, 2x artifact storage)
- **DynamoDB**: 1 table with GSI
- **KMS**: 2 CMKs (S3/DynamoDB)
- **IAM**: 6 roles + 2 managed policies
- **Lambda**: 1 function
- **CodePipeline**: 2 pipelines
- **CodeBuild**: 2 projects
- **SNS**: 2 topics

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies (wildcard actions/resources)
- **Duplication**: Redundant environment templates (oht-environ.yaml vs oht-environment.yaml)
- **Hardcoding**: Fixed Lambda timeout (900s) and memory (3008MB)
- **Missing Logging**: No CloudTrail/VPC Flow Logs
- **IAM Credentials**: GitHub token stored as plaintext parameter

## 5. Technical Debt
- **Modularization**: Single monolithic environment template
- **Parameter Sprawl**: 23 parameters in main template
- **Resource Naming**: Inconsistent naming conventions ("rDynamoTable" vs "rCsvToDDBLambdaFunction")
- **State Management**: No drift detection mechanisms

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings for core services (S3/DynamoDB/IAM/Lambda)
- Requires decomposition of monolithic templates into modules
- Complex IAM policy restructuring needed
- Pipeline conversion requires careful state management

## 7. Recommended Migration Path
1. Establish Terraform environment (S3 backend + DynamoDB lock table)
2. Create core modules:
   - S3 buckets (storage/archive patterns)
   - DynamoDB (table + GSI + KMS)
   - Lambda (function + role + permissions)
3. Migrate CI/CD infrastructure last:
   - CodeBuild → Terraform first
   - CodePipeline depends on artifacts
4. Use environment workspaces for dev/prod separation
5. Validate with `terraform plan` before applying

