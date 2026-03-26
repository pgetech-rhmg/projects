# Repository Assessment: gis-geomartcloud-wsoc-api-emailwildfireincident

## 1. Overview
This CloudFormation template provisions a secure API Gateway endpoint for wildfire incident email notifications. It deploys a private API backed by a Lambda function with VPC integration, using environment-specific configurations and centralized parameter management.

## 2. Architecture Summary
- **Core Pattern**: Serverless API pattern with VPC-enabled Lambda
- **Primary Services**: API Gateway (private endpoint), Lambda, IAM, Secrets Manager, SES, SNS, CloudWatch Logs
- **Security Model**: Uses SSM Parameter Store for secrets, KMS encryption for Lambda environment variables, and VPC isolation
- **Environment Handling**: Parameterized environment configuration with standardized tagging

## 3. Identified Resources
- API Gateway REST API (private endpoint)
- Lambda function (Python 3.9 runtime)
- IAM roles (Lambda execution + API Gateway integration)
- Security group (self-referential ingress)
- CORS configuration
- API Gateway authorizer (Lambda-backed)
- CloudWatch Logs integration

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: 
  - Lambda role has s3:*, kms:*, secretsmanager:*, and ec2:Describe* permissions
  - API Gateway role allows lambda:* on function ARN
- **Hard-Coded Secrets**: DT_CONNECTION_AUTH_TOKEN appears static
- **Missing Dead Letter Queue**: SQS configuration commented out
- **Insecure CORS**: Access-Control-Allow-Origin: "*"
- **VPC Endpoint Validation**: Hard-coded region in AuthorizerUri
- **Lambda Environment Variables**: Potential secret leakage in DT_TAGS

## 5. Technical Debt
- **Parameter Sprawl**: 16 parameters with inconsistent naming conventions
- **Tight Coupling**: Security group references itself for ingress
- **Hard-Coded Values**: 
  - Lambda memory (1024MB) and timeout (300s)
  - Fixed VPC subnet references
  - Static Dynatrace configuration
- **Missing Modularization**: Single monolithic template

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for core resources
- Requires:
  - Refactoring IAM policies into data blocks
  - Decomposing environment parameters
  - Handling SSM parameter references
  - Converting Fn::Sub syntax

## 7. Recommended Migration Path
1. Establish Terraform state backend (S3+DynamoDB)
2. Create parameter mappings for SSM values
3. Migrate IAM roles first as modules
4. Implement VPC resources as separate module
5. Convert Lambda configuration with environment variables
6. Migrate API Gateway components
7. Validate private endpoint configuration

