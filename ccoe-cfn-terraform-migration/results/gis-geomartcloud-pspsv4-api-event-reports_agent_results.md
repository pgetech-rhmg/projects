# Repository Assessment: gis-geomartcloud-pspsv4-api-event-reports

## 1. Overview
The CloudFormation template provisions a serverless API solution for event report handling using API Gateway, Lambda, SQS, and IAM. It includes CORS configuration, VPC integration, and environment-specific parameters.

## 2. Architecture Summary
- **API Gateway**: Private REST API with POST endpoints for job creation
- **Lambda Functions**: Python 3.7 handlers for job processing with VPC networking
- **SQS**: Message queue with optional dead-letter queue
- **Security**: IAM roles with broad permissions and VPC-restricted SQS access
- **Networking**: Lambda deployed in 3 private subnets with security group isolation

## 3. Identified Resources
- 1x API Gateway REST API (private endpoint)
- 2x IAM Roles (Lambda execution + API Gateway)
- 1x SQS Queue (with dead-letter queue option)
- 1x EC2 Security Group
- 2x Lambda Functions (createjob only - jobstatus commented out)
- 1x API Gateway Authorizer
- 1x SQS Queue Policy

## 4. Issues & Risks
- **Security**:
  - IAM roles use overly permissive policies (s3:*, secretsmanager:*, kms:*, sqs:*)
  - API Gateway policy allows execute-api:Invoke (undocumented action)
  - SQS policy uses deprecated "aws:SourceVpc" condition
  - Hardcoded AWS account ID in resource policies
- **Configuration**:
  - Missing dead-letter queue configuration details
  - Lambda functions have commented-out code blocks
  - API Gateway depends on non-existent rLambdaSecurityGroup
  - Duplicate pOrderNumber parameter declaration
  - Lambda VPC configuration may require NAT gateway

## 5. Technical Debt
- **Hardcoded Values**: AWS account ID in policy resources
- **Modularization**: Single template handles all components
- **Environment Handling**: Uses both pEnv and pTaskEnv parameters
- **Resource Naming**: Inconsistent capitalization (rCreatejobLambdaFunction vs rjobstatusLambdaFunction)
- **Policy Management**: No least-privilege IAM practices

## 6. Terraform Migration Complexity
Moderate complexity:
- Straightforward resource mappings exist for all components
- Requires:
  - Refactoring IAM policies to Terraform syntax
  - Handling conditional resources (dead-letter queue)
  - Decomposing into modules (networking, compute, security)
  - Managing parameter dependencies

## 7. Recommended Migration Path
1. Create Terraform state bucket with DynamoDB locking
2. Develop networking module (VPC/subnet references)
3. Migrate IAM roles with policy documents
4. Convert SQS resources with conditional logic
5. Implement Lambda functions and API Gateway
6. Validate private endpoint configuration
7. Incremental deployment:
   - First deploy IAM and networking
   - Then SQS and Lambda
   - Finally API Gateway configuration

