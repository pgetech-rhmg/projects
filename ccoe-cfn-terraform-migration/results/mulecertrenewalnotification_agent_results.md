# Repository Assessment: mulecertrenewalnotification

## 1. Overview
The repository contains a SAM-based CloudFormation template that deploys a scheduled AWS Lambda function for MuleSoft certificate renewal notifications. The infrastructure uses DynamoDB for storage and SES for email notifications.

## 2. Architecture Summary
- **Core Service**: AWS Lambda (Java 17 runtime) scheduled to run daily
- **Trigger**: CloudWatch Events cron schedule (11:00 UTC)
- **Data Source**: DynamoDB table (MULE_CERT_STORE)
- **Notification**: SES email service
- **Environment**: Hardcoded DEV configuration

## 3. Identified Resources
- AWS::Serverless::Function (Lambda)
- Implicit IAM Role with:
  - DynamoDB read access
  - SES email permissions
  - AWSLambdaBasicExecutionRole

## 4. Issues & Risks
- **Security**: SES policy uses wildcard resource ("*") instead of scoped permissions
- **Environment Handling**: Hardcoded DEV values in Globals section
- **Missing Configuration**:
  - No VPC configuration (Lambda runs in default VPC)
  - No dead-letter queue for failed notifications
  - No SES configuration set verification
- **IAM Anti-Pattern**: Inline policy instead of managed policies

## 5. Technical Debt
- **Hardcoded Values**: 
  - Environment variables (ENV, EMAIL_FROMADDRESS)
  - Tag values (Environment: DEV)
- **No Parameterization**: Critical values aren't using CloudFormation Parameters
- **No Environment Separation**: Single template for all environments
- **Missing Lifecycle Controls**: No retention policies or TTL configurations

## 6. Terraform Migration Complexity
Moderate. Key considerations:
- SAM transform requires conversion to native Terraform resources
- Inline policies would need refactoring to AWS IAM modules
- Event scheduling syntax differs between CFN and Terraform
- Would require decomposition of Globals into Terraform variables

## 7. Recommended Migration Path
1. Create Terraform module structure (lambda, iam, events)
2. Migrate DynamoDB policy to aws_iam_policy_document
3. Replace inline SES policy with aws_iam_role_policy_attachment
4. Convert SAM event schedule to aws_cloudwatch_event_rule
5. Parameterize all environment variables using Terraform variables
6. Implement environment-specific backend configurations

