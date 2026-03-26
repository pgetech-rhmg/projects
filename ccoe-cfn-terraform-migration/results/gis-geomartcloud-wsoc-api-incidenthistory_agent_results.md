# Repository Assessment: gis-geomartcloud-wsoc-api-incidenthistory

## 1. Overview
This CloudFormation template provisions a serverless API solution for incident history management using API Gateway, Lambda, SQS, and IAM. It includes environment-specific configurations, VPC integration, and basic security controls.

## 2. Architecture Summary
- **API Gateway**: Private REST API with CORS support and custom Lambda authorizer
- **Lambda Functions**: Two Python 3.9 functions (createjob/jobstatus) with VPC integration
- **SQS**: Main queue with dead-letter queue support
- **IAM**: Roles with broad permissions for Lambda and API Gateway
- **Security**: Security group with self-referential ingress rule

## 3. Identified Resources
- 1x API Gateway REST API (private endpoint)
- 2x Lambda Functions (Python 3.9)
- 2x SQS Queues (main + dead-letter)
- 3x IAM Roles (Lambda execution + API Gateway)
- 1x Security Group
- 1x Custom Authorizer

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (s3:*, kms:*, sqs:*) violate least privilege
  - Hardcoded AWS account ID in API policy
  - Potential secrets exposure in Lambda environment variables
  - Missing VPC endpoint services for Lambda
  - Public CORS configuration (Access-Control-Allow-Origin: '*')

- **Configuration**:
  - SQS dead-letter queue missing RedrivePolicy parameters
  - Lambda functions use deprecated inline policy statements
  - Missing resource-based policies for SQS/Lambda
  - Hardcoded region in Lambda authorizer ARN

- **Reliability**:
  - No deployment validation/rollback mechanisms
  - Missing DLQ configuration for Lambda async invocations

## 5. Technical Debt
- **Modularization**: Single template with 300+ lines
- **Hardcoding**: 
  - Account IDs in resource policies
  - Region values in Lambda ARNs
  - Magic strings in IAM policy names
- **Parameter Sprawl**: 19 parameters with inconsistent naming
- **Missing Features**:
  - No logging configuration for Lambda
  - No X-Ray sampling configuration
  - No output values for critical resources

## 6. Terraform Migration Complexity
Moderate complexity due to:
- Extensive use of intrinsic functions
- Complex IAM policy documents
- VPC configuration requirements
- Need to decompose into Terraform modules

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles
   - Lambda functions
   - API Gateway configuration
   - SQS queues
2. Replace SSM parameter lookups with Terraform data sources
3. Refactor IAM policies using aws_iam_policy_document
4. Migrate SQS configuration first
5. Implement gradual Lambda migration with blue/green deployments
6. Validate API Gateway behavior before final cutover

