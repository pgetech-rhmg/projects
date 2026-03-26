# Repository Assessment: gis-geomartcloud-wsoc-batch-geoincidenthistory

## 1. Overview
The repository contains a CloudFormation template for deploying a Lambda-based batch processing system named "GeoIncidentHistory" in the WSOC environment. The infrastructure focuses on Lambda execution with VPC connectivity, SQS event triggers, and IAM permissions for various AWS services.

## 2. Architecture Summary
The solution uses:
- AWS Lambda for compute with Python 3.9 runtime
- IAM Role with broad permissions for logging, S3, SQS, RDS, ECS, and SecretsManager
- VPC integration with private subnets and security group
- SQS queue as event source for Lambda triggers
- Environment variables for Dynatrace integration
- SSM Parameter Store for configuration management

## 3. Identified Resources
- **Active**:
  - IAM::Role (Lambda execution role)
  - EC2::SecurityGroup (Lambda security group)
  - EC2::SecurityGroupIngress (Self-referenced SG rule)
  - Lambda::Function (Main processing function)
  - Lambda::EventSourceMapping (SQS trigger configuration)
- **Inactive/Commented**:
  - ECS TaskDefinition, Roles, LogGroup
  - SecretsManager Secret
  - Additional Lambda configuration

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies with 11x Resource:"*" statements
  - Hardcoded Dynatrace API token in environment variables
  - Missing encryption configuration for SQS queue
  - Public exposure risk if VPC endpoints aren't properly configured
- **Configuration**:
  - Inconsistent environment parameter casing (pEnv vs pTaskEnv)
  - Missing error handling in Lambda code skeleton
  - Duplicate VPC ID parameters (VPC and pVPCID)
  - Unused parameters (pypackages, psycopg, etc.)

## 5. Technical Debt
- **Modularization**:
  - Single monolithic template with 300+ lines
  - No nested stacks or modules
- **Hardcoding**:
  - Fixed region in Lambda layer ARNs ("us-west-2")
  - Magic numbers in Lambda config (MemorySize:3008, Timeout:350)
- **Maintainability**:
  - 67 lines of commented-out resources
  - 15 environment variables directly in template
  - No parameter validation for Python package versions

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for IAM, Lambda, and VPC resources
- Would require:
  - Decomposing IAM policy documents
  - Refactoring environment variables into variables.tf
  - Handling SSM parameter references with data sources
  - Restructuring into Terraform modules (lambda/, iam/, vpc/)

## 7. Recommended Migration Path
1. Create Terraform state bucket with DynamoDB locking
2. Build core network module (VPC references)
3. Migrate IAM role with policy decomposition
4. Convert Lambda function and SQS mapping
5. Implement parameter management with terraform.tf

