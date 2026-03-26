# Repository Assessment: gis-geomartcloud-mab-api-photofetch

## 1. Overview
The CloudFormation template creates a private API Gateway endpoint backed by DynamoDB tables for photo retrieval in a MAB application. Uses Lambda authorizer and VPC endpoint restrictions for security.

## 2. Architecture Summary
- **Core Services**: API Gateway (HTTP API), DynamoDB, IAM, SSM Parameter Store
- **Pattern**: Serverless REST API with database backend
- **Security**: Private endpoint, Lambda authorizer, VPC endpoint policy
- **Environments**: Supports prod/qa/tst/dev via parameters

## 3. Identified Resources
- IAM Role (API Gateway execution role)
- API Gateway (HTTP API with Lambda integration)
- SSM Parameter (API Gateway URL storage)
- API Gateway Authorizer (Lambda-backed)

## 4. Issues & Risks
- **Overly Permissive KMS Policy**: kms:* on all resources
- **Missing Lambda Definition**: Lambda authorizer references undefined function
- **CORS Misconfiguration**: Allows all origins in OPTIONS response
- **Hardcoded Region**: AuthorizerUri uses us-west-2
- **Redundant Auth Sections**: Duplicate Auth blocks in APIGW resource
- **Missing Logging**: Only ERROR-level logging enabled

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with inconsistent naming
- **Tight Coupling**: Hardcoded index names in request templates
- **No Throttling**: No usage plans or rate limiting
- **No Output Encryption**: SSM parameter value not encrypted
- **No Lifecycle Management**: No retention policies

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean mapping for APIGW/IAM/DynamoDB
- Requires:
  - Refactoring SSM parameters
  - Decomposing inline policies
  - Adding missing Lambda resource
  - Handling APIGW v1/v2 differences

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles
   - API Gateway configuration
   - DynamoDB integration
   - Lambda authorizer
2. Migrate parameters to Terraform variables
3. Implement missing Lambda function
4. Validate VPC endpoint policies
5. Add resource tagging

