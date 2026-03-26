# Repository Assessment: pge-crm-view-refresh-lambda

## 1. Overview
The repository contains AWS CloudFormation templates for deploying a scheduled Lambda function that refreshes database views, integrated with CI/CD pipelines using AWS CodePipeline and CodeBuild. The solution includes environment-specific configurations for dev/tst/qa environments, parameter management via SSM/Secrets Manager, and SNS notifications.

## 2. Architecture Summary
- **Core Service**: AWS Lambda (Java 8 runtime) running in VPC with scheduled triggers
- **Eventing**: EventBridge rules for hourly/daily execution
- **CI/CD**: CodePipeline with CodeBuild projects for build/deploy automation
- **Security**: IAM roles with managed policies, KMS encryption for SNS
- **Observability**: SNS notifications for failures
- **Environments**: Separate stacks for dev/tst/qa with shared pipeline structure

## 3. Identified Resources
- **Lambda**: Function, Execution Role, IAM Policies
- **EventBridge**: Scheduled Rules, Permissions
- **SNS**: Topic with encryption, Topic Policy
- **IAM**: Roles (Lambda, CodeBuild, CodePipeline), Policies
- **CodePipeline**: Pipeline, Webhook, Notification Rules
- **CodeBuild**: Projects (build/deploy), Security Groups

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: CodeBuild/CodePipeline roles have wildcard resource access
- **Hardcoded Security Group IDs**: Lambda uses direct SSM parameter references instead of lookups
- **Missing Dead Letter Queues**: SNS subscriptions lack DLQ configuration
- **Unrestricted SNS Access**: SNS topic policy allows root/broad access
- **Privilege Escalation**: CodeBuild projects use privileged mode
- **Region Hardcoding**: SNS topic ARN uses us-west-2 in policy

## 5. Technical Debt
- **Parameter Sprawl**: 40+ parameters per environment with many unused
- **Code Duplication**: Near-identical CodePipeline stacks for each environment
- **Missing Lifecycle Management**: No retention policies for S3 artifacts
- **Inconsistent Tagging**: Some resources lack full tagging
- **Hardcoded Values**: JFrog configuration uses direct SSM references

## 6. Terraform Migration Complexity
Moderate complexity:
- **Clean Mapping**: Lambda, SNS, IAM, EventBridge map directly to Terraform
- **Modularization Required**: CodePipeline/CodeBuild need refactoring
- **State Management**: Pipelines would require remote state configuration
- **SSM/Secrets Handling**: Would need data resource lookups

## 7. Recommended Migration Path
Not Observed

