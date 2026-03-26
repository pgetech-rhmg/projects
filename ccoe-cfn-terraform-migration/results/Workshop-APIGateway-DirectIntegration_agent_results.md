# Repository Assessment: Workshop-APIGateway-DirectIntegration

## 1. Overview
This CloudFormation template creates foundational infrastructure for an API Gateway workshop including S3 storage, DynamoDB database, and IAM roles for service access.

## 2. Architecture Summary
The solution establishes:
- S3 bucket with server-side encryption for static assets
- DynamoDB table with GSI for sports data
- Two IAM roles granting API Gateway access to both services

## 3. Identified Resources
- AWS::S3::Bucket (1 instance)
- AWS::DynamoDB::Table (1 instance)
- AWS::IAM::Role (2 instances)

## 4. Issues & Risks
- **Security**: IAM roles use "dynamodb:*" and "s3:*" permissions - violates least privilege
- **Networking**: No VPC endpoints configured for private API Gateway integrations
- **Hardcoding**: Service-linked role names (apigateway-db-sportstable-access-role) reduce reusability
- **Missing Logging**: No explicit CloudTrail/S3 logging configuration

## 5. Technical Debt
- **Parameterization**: DynamoDB throughput hardcoded at 5 RCU/WCU
- **Modularization**: Single template combines storage, database, and permissions
- **Environment Handling**: No environment-specific parameters or resource naming

## 6. Terraform Migration Complexity
Moderate complexity:
- Direct resource mappings exist for S3/DynamoDB/IAM
- Requires:
  - Refactoring IAM policies to Terraform syntax
  - Adding missing VPC endpoint configurations
  - Decomposing into logical modules (storage, database, networking)

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - S3 bucket with encryption
   - DynamoDB table with GSI
   - IAM roles with scoped policies
2. Migrate storage layer first (S3 bucket)
3. Implement DynamoDB table with proper throughput parameters
4. Refactor IAM roles using Terraform aws_iam_policy_document
5. Add VPC endpoint resources for private connectivity

