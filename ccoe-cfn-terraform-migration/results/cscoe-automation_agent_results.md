# Repository Assessment: cscoe-automation

## 1. Overview
The repository contains CloudFormation templates for three distinct security automation solutions:
1. Phishing reinforcement system (3 files)
2. Delayed organizational state machine (1 file)
3. Cross-account VPC removal (2 files)

Key characteristics:
- Uses AWS SAM for Lambda deployments
- Implements cross-account access patterns
- Includes security-focused automations
- Contains both application and infrastructure deployment templates

## 2. Architecture Summary
- **Phishing Reinforcement**: 
  - Lambda functions interact with ProofPoint API and DynamoDB
  - SES integration for email notifications
  - Cross-account IAM roles for email sending
  - VPC-enabled Lambda functions with KMS encryption

- **Delayed State Machine**:
  - Step Functions state machine with Lambda integrations
  - Organizational account management capabilities
  - Time-delayed state transitions
  - Uses managed policies for Lambda permissions

- **VPC Removal**:
  - Cross-account Lambda pattern for VPC cleanup
  - EC2FullAccess policy in target accounts
  - Serverless application pattern
  - Focuses on default VPC deletion

## 3. Identified Resources
- IAM Roles/Policies (14 total)
- Lambda Functions (6 total)
- DynamoDB Table (1)
- KMS Keys/Aliases (4)
- S3 Bucket (1)
- Step Functions State Machine (1)
- SNS/SES configurations (implicit)

## 4. Issues & Risks
- **Overly Permissive Permissions**:
  - S3 bucket policy uses "s3:*" in multiple places
  - Lambda base policy grants "s3:*" and "ssm:*"
  - Cross-account roles use full EC2 access
  - SES policy allows sending to any address

- **Hard-Coded Values**:
  - Master account ID in delayedfsm.yaml
  - Shared services account number in VPC removal
  - Default parameter values throughout

- **Security Gaps**:
  - Missing encryption at rest for S3 bucket (VersioningConfiguration disabled)
  - No VPC endpoints shown for Lambda functions
  - Lambda functions have public internet access via VPC config
  - No explicit logging configuration

- **Anti-Patterns**:
  - Managed policy with "Resource: *" in multiple places
  - Lambda environment variables stored as plaintext
  - No least-privilege application of KMS permissions

## 5. Technical Debt
- **Modularization**:
  - Shared resources (KMS, S3) duplicated across stacks
  - No nested stacks or modules
  - Cross-account dependencies not abstracted

- **Environment Management**:
  - No environment-specific parameters
  - Hard-coded dev/test values
  - No separation between app/infra deployments

- **Maintainability**:
  - Complex IAM policy documents
  - High resource count per template
  - No standardized tagging strategy

## 6. Terraform Migration Complexity
Moderate to High complexity:
- SAM transforms require conversion to native Terraform
- Cross-account IAM would need provider configuration
- Step Functions state machine has complex substitutions
- KMS key management differs between CFN/Terraform
- Would require significant refactoring of:
  - IAM policies

## 7. Recommended Migration Path
Not Observed

