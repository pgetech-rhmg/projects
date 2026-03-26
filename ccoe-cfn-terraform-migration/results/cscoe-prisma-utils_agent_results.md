# Repository Assessment: cscoe-prisma-utils

## 1. Overview
This repository contains CloudFormation templates for managing Prisma Cloud (Twistlock) integration with AWS. It implements centralized key storage, automated credential rotation, and access management across multiple accounts.

## 2. Architecture Summary
The solution uses:
- KMS for encryption key management
- Secrets Manager for secure credential storage
- IAM roles/policies for cross-service permissions
- Scheduled Lambda functions for:
  - Credential rotation (every 45 days)
  - Access key monitoring
  - Cross-account role assumption
- SES for email notifications
- Parameter Store for configuration management

## 3. Identified Resources
- AWS::KMS::Key
- AWS::KMS::Alias
- AWS::SecretsManager::Secret
- AWS::SecretsManager::ResourcePolicy
- AWS::IAM::Role
- AWS::IAM::ManagedPolicy
- AWS::Serverless::Function
- AWS::IAM::User (in twistlock-user template)

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Many resources use "*" permissions (e.g., ec2:* in rTwistlockLambdaRole)
- **Hardcoded ARNs**: Explicit account IDs in rIAMAssumerole
- **Missing VPC Endpoints**: Lambda functions access external services without VPC endpoints
- **Insecure Lambda Environment Variables**: Hardcoded URLs in environment variables
- **Key Rotation Gap**: KMS key rotation enabled but no automation for application consumption
- **Inconsistent Timeout Values**: Lambda timeouts vary between 15m (global) and 15h (explicit)

## 5. Technical Debt
- **Parameter Duplication**: Repeated SSM parameter references across templates
- **Inconsistent Tagging**: Only twistlock-user template implements resource tagging
- **Hardcoded Service Limits**: Lambda memory/timeout values not parameterized
- **Missing Dead-Letter Queues**: No error handling for scheduled events
- **SAM Transform Dependency**: Requires Serverless Application Model

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- SAM transform translation requiring AWS Lambda module
- Complex IAM policy documents needing HCL conversion
- Resource dependency management between KMS/Secrets/Lambda
- Parameter Store integration requiring SSM data source

## 7. Recommended Migration Path
1. Convert core infrastructure (KMS/Secrets) first
2. Create Terraform modules for:
   - IAM roles with policy attachments
   - Lambda functions with VPC config
   - Scheduled events
3. Use data sources for SSM parameters
4. Maintain parallel CFN/Terraform environments during transition
5. Validate with AWS Config rules before decommissioning CFN stacks

