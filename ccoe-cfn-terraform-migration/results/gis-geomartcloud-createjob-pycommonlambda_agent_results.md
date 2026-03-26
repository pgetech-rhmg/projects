# Repository Assessment: gis-geomartcloud-createjob-pycommonlambda

## 1. Overview
This repository contains a CloudFormation template for deploying a Python Lambda function ("pycommonlambda") with associated IAM role and security group. The infrastructure appears focused on geospatial job processing with compliance tagging and environment-specific configurations.

## 2. Architecture Summary
- **Core Service**: AWS Lambda (Python 3.7 runtime)
- **Supporting Services**: IAM (role + policies), VPC networking (security group), CloudWatch Logs
- **Pattern**: Serverless compute with broad AWS service permissions
- **Environments**: Supports prod/qa/tst/dev via parameters

## 3. Identified Resources
- IAM Role (rLambdaFunctionRole) with 13 managed policies
- EC2 Security Group (rLambdaSecurityGroup)
- Lambda Function (rpycommonLambdaFunction) with VPC configuration

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Uses 10+ wildcard (*) resource policies including ec2:*, s3:*, cloudwatch:*
- **Hardcoded Security Group Name**: Risk of name collisions across environments
- **Missing VPC Flow Logs**: No network visibility configuration
- **Public Lambda Exposure**: No API Gateway/authorizer configuration shown
- **Deprecated Runtime**: Python 3.7 reaches EOL 2023-06-27

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with inconsistent naming conventions
- **Inline Policy Documents**: Should be externalized for reuse
- **No Resource Deletion Protection**: Missing DeletionPolicy attributes
- **Environment Coupling**: Uses both pEnv and pTaskEnv parameters

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for IAM, SG, Lambda
- Would require:
  - Refactoring inline policies to modules
  - Parameter normalization
  - VPC dependency handling
  - Lambda layer ARN construction

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM role with external policy files
   - Security group with name suffix
   - Lambda function with environment variables
2. Migrate parameters to Terraform variables with validation
3. Implement state management per environment
4. Validate with CloudFormation drift detection

