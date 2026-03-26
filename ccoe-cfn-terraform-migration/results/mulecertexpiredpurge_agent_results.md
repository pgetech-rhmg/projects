# Repository Assessment: mulecertexpiredpurge

## 1. Overview
The repository contains a SAM-based CloudFormation template for a scheduled Lambda function that purges expired certificates from a DynamoDB table. Targets Java 17 runtime with x86_64 architecture and 512MB memory allocation.

## 2. Architecture Summary
- **Core Service**: AWS Lambda (Java 17) with scheduled execution
- **Trigger**: CloudWatch Events cron job (daily at 4:00 AM UTC)
- **Data Source**: DynamoDB table (MULE_CERT_STORE)
- **Security**: Managed IAM role with DynamoDBCrudPolicy

## 3. Identified Resources
- AWS::Serverless::Function (mulecertexpiredpurgeFunction)
- Implicit IAM Role (via DynamoDBCrudPolicy)
- CloudWatch Events Rule (Schedule trigger)

## 4. Issues & Risks
- **Security**: 
  - DynamoDBCrudPolicy grants full CRUD access - consider least privilege
  - Hardcoded ENV=DEV in environment variables
  - Missing encryption configuration for environment variables
- **Configuration**:
  - Cron expression uses UTC (0 12 1 * ? *) instead of local time
  - No dead-letter queue (DLQ) for error handling
  - Missing DynamoDB table definition in template

## 5. Technical Debt
- Hardcoded values: ENV, table name, and schedule
- No parameter store integration
- Environment-specific values in global configuration
- No resource-level tagging overrides

## 6. Terraform Migration Complexity
Moderate. Requires:
- SAM-to-Terraform translation for Lambda+IAM
- Refactoring inline policies to Terraform syntax
- Schedule expression conversion
- Handling implicit resources explicitly

## 7. Recommended Migration Path
1. Create Terraform module structure (lambda, iam, events)
2. Migrate IAM role as explicit aws_iam_role
3. Convert Lambda resource using aws_lambda_function
4. Translate schedule to aws_cloudwatch_event_rule
5. Replace hardcoded values with variables
6. Validate IAM policy equivalence

