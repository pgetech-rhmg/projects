# Repository Assessment: emergency-website-s3-web-policy

## 1. Overview
This CloudFormation template creates a Lambda function to manage S3 website redirect policies with associated IAM permissions and deployment configuration.

## 2. Architecture Summary
Deploys a Lambda function with S3/SSM permissions to update bucket policies. Uses SSM Parameter Store for application metadata and includes a custom resource for Lambda triggers.

## 3. Identified Resources
- **IAM Role**: Lambda execution role with broad S3/SSM/Logs permissions
- **Lambda Function**: Python 3.7 handler for policy updates
- **Custom Resource**: LambdaTrig (implementation unknown)

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies (ssm:*, s3:*, logs:*) violate least privilege
- **Configuration**: Hardcoded default Lambda name ("S3BucketPolicy")
- **Deprecation**: Uses Python 3.7 runtime (end-of-life 2023-06-27)
- **Missing Components**: No VPC configuration for Lambda
- **Custom Resource**: Unknown implementation of Custom::LambdaTrig

## 5. Technical Debt
- **Hardcoded Values**: Default Lambda name and S3 bucket references
- **Parameter Sprawl**: 14 parameters with overlapping purposes
- **No Environment Separation**: Single template for all environments
- **No Lifecycle Controls**: No retention policies or versioning

## 6. Terraform Migration Complexity
Moderate. Requires:
1. Refactoring IAM policies
2. Decomposing custom resource logic
3. Parameterizing environment variables
4. Updating deprecated runtime

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM role (with scoped policies)
   - Lambda function
   - S3 bucket references
2. Replace Custom::LambdaTrig with native Terraform resources
3. Migrate SSM parameters to Terraform variables
4. Implement environment-specific configurations

