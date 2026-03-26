# Repository Assessment: gis-geomartcloud-wsoc-api-siptassignmenthistory

## 1. Overview
The CloudFormation template provisions a serverless API solution for SIPT Assignment History management using API Gateway, Lambda functions, SQS queues, and IAM roles. The infrastructure supports job creation and status checking with VPC integration and CORS configuration.

## 2. Architecture Summary
- **API Gateway**: Private REST API with CORS support and custom Lambda authorizer
- **Lambda Functions**: Two Python 3.9 functions (createjob/jobstatus) with VPC integration
- **SQS**: Main queue with optional dead-letter queue
- **IAM**: Overly permissive roles with wildcard resource policies
- **Security**: VPC-restricted API access and Lambda execution

## 3. Identified Resources
- AWS::ApiGateway::RestApi
- AWS::Lambda::Function (x2)
- AWS::SQS::Queue (x2)
- AWS::IAM::Role (x3)
- AWS::EC2::SecurityGroup
- AWS::ApiGateway::Authorizer
- AWS::ApiGateway::Method (x4)

## 4. Issues & Risks
- **Security**:
  - IAM roles use wildcard permissions ("Resource: '*'") for S3, SecretsManager, KMS, SQS, and Config
  - Hardcoded Dynatrace credentials in Lambda environment variables
  - Missing encryption configuration for SQS dead-letter queue
  - API Gateway policy allows execute-api:Invoke from any principal
- **Reliability**:
  - No DLQ configuration validation
  - Missing error handling in Lambda functions
- **Operational**:
  - No CloudWatch alarms or logging configuration
  - Lambda timeout set to maximum (300s) without justification

## 5. Technical Debt
- Duplicated parameters (pOrderNumber appears twice)
- Hardcoded region references ("us-west-2")
- No environment-specific resource naming
- Missing output values for critical resources (Lambda ARNs)
- No parameter validation for Lambda package versions

## 6. Terraform Migration Complexity
Moderate complexity:
- Standard resource types map directly to Terraform providers
- Would require:
  - Refactoring IAM policies to use data sources
  - Modularization into resource-specific modules
  - Secret management integration
  - Removal of hardcoded values

## 7. Recommended Migration Path
1. Create Terraform state backend configuration
2. Migrate parameters to variables.tf
3. Implement IAM roles with aws_iam_policy_document
4. Convert SQS resources with proper encryption
5. Migrate Lambda functions with environment variable management
6. Refactor API Gateway configuration
7. Validate with terraform plan/apply

