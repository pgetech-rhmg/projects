# Repository Assessment: gis-geomartcloud-pspsv4-batch-epssevent

## 1. Overview
The CloudFormation template provisions a serverless batch processing pipeline using AWS Lambda, ECS Fargate, Step Functions, and CloudWatch. It deploys two Lambda functions (invoke and processing), two ECS task definitions (circuit and coverage), and a parallel state machine workflow. The infrastructure includes security groups, IAM roles, and logging configurations.

## 2. Architecture Summary
- **Core Services**: Lambda, ECS Fargate, Step Functions, CloudWatch Logs, IAM
- **Pattern**: Event-driven batch processing with parallel execution branches
- **Workflow**:
  1. SQS triggers Lambda function
  2. Step Functions orchestrates parallel ECS Fargate tasks
  3. Final Lambda invocation for post-processing
- **Security**: Uses SSM Parameter Store for secrets, but contains overly permissive IAM policies

## 3. Identified Resources
- IAM Roles (4): Lambda execution, ECS task, Step Functions, Lambda invoke
- Lambda Functions (2): Main processing and invoke functions
- ECS Task Definitions (2): Circuit and coverage batch jobs
- Security Groups (2): For Lambda and ECS
- CloudWatch Log Groups (3): For ECS tasks and Step Functions
- Step Functions State Machine: Parallel execution workflow

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (Resource: "*") across all roles
  - Missing S3 bucket encryption configuration
  - Public IP assignment enabled for ECS tasks
  - Lambda functions use deprecated Python 3.7 runtime
  - No VPC flow logs enabled
- **Configuration**:
  - Hardcoded region references ("us-west-2")
  - Missing dead-letter queue configuration for SQS
  - No retries/error handling in Step Functions
  - Lambda timeout set to maximum (900s) without justification

## 5. Technical Debt
- **Modularization**: Single monolithic template with 20+ resources
- **Hardcoding**: 
  - Fixed region in Lambda layer ARNs
  - Magic numbers for CPU/memory
  - Inline policy documents instead of managed policies
- **Maintainability**:
  - Duplicated IAM policy statements between roles
  - No parameter validation for critical values
  - Missing output exports for resource references

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires decomposition into modules (IAM, ECS, Lambda, SFN)
- Inline policies would need conversion to aws_iam_policy_document
- Step Functions JSON would require variable interpolation
- Parallel resource dependencies would need careful ordering

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM roles and policies
   - Lambda functions
   - ECS task definitions
   - Step Functions state machine
2. Migrate parameters to Terraform variables with validation
3. Convert inline policies to managed policy attachments where possible
4. Implement resource tagging through locals
5. Validate with `terraform plan` against existing stack

