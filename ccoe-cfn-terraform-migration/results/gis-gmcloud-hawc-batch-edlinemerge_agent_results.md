# Repository Assessment: gis-gmcloud-hawc-batch-edlinemerge

## 1. Overview
Partial CloudFormation template for HAWC batch processing infrastructure with Lambda function and EFS integration. Focuses on data processing with security controls but shows signs of incomplete implementation.

## 2. Architecture Summary
- Core components: Lambda function with EFS mount for batch processing
- Security: Uses IAM role with managed policies and inline permissions
- Environment configuration: Parameterized for multiple environments (prod/qa/dev)
- Missing components: VPC/security group definitions, event triggers

## 3. Identified Resources
- AWS::IAM::Role (Lambda execution role)
- AWS::Lambda::Function (Batch processing function with EFS integration)

## 4. Issues & Risks
- **Overly permissive IAM policies**: 
  - SecretsManager:* on all secrets
  - KMS:* on all keys
  - S3:* on environment buckets
  - DynamoDB:* on all tables
  - RDS Deny rule uses wildcard resource
- **Hardcoded values**: Lambda timeout (900s), memory (1024MB), and runtime (python3.7)
- **Security parameter mismatch**: pApplicationName/pAppID descriptions reference security groups
- **Missing VPC configuration**: Security group references but no definitions
- **Inconsistent environment parameters**: pEnv vs pTaskEnv casing

## 5. Technical Debt
- **Inline policy duplication**: Multiple S3/SNS/DynamoDB statements
- **Parameter sprawl**: 23 parameters with overlapping purposes
- **No resource dependencies**: Lambda function missing DependsOn for security groups
- **No lifecycle management**: No retention policies or deletion protections

## 6. Terraform Migration Complexity
Moderate complexity:
- IAM policies require HCL conversion
- EFS integration maps cleanly to Terraform
- Would need parameter reorganization
- Missing VPC resources would require external references

## 7. Recommended Migration Path
1. Convert IAM role to Terraform module with policy files
2. Migrate Lambda function using aws_lambda_function resource
3. Parameterize VPC/security group references
4. Validate environment handling consistency
5. Implement missing resource dependencies

