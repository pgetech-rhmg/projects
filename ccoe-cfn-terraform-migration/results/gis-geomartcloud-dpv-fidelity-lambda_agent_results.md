# Repository Assessment: gis-geomartcloud-dpv-fidelity-lambda

## 1. Overview
This CloudFormation template provisions a scheduled Lambda function with broad AWS service permissions for a geospatial data processing application. Includes IAM roles, security groups, and EventBridge scheduling.

## 2. Architecture Summary
- **Core Service**: AWS Lambda function deployed in VPC
- **Trigger**: EventBridge scheduled rule (daily execution)
- **Permissions**: Overly permissive IAM policies for multiple AWS services
- **Security**: VPC-enabled Lambda with security group

## 3. Identified Resources
- IAM Roles (2)
- Lambda Function (Python 3.7)
- EC2 Security Group
- EventBridge Rule
- Lambda Permission
- IAM Policy

## 4. Issues & Risks
- **Security**:
  - IAM policies use `Resource: "*"` for 10+ services (logs, S3, EC2, SES, etc.)
  - Missing VPC endpoints for S3/DynamoDB access
  - Lambda runtime hardcoded to python3.7 (deprecated)
  - No encryption configuration for CloudWatch logs
- **Configuration**:
  - SubnetID parameters use `Ref` instead of `!Ref`
  - EventBridge rule references undefined `rEventruleRole`
  - Lambda environment variables only include ENV parameter

## 5. Technical Debt
- **Hardcoded Values**: Lambda runtime version
- **Parameter Sprawl**: 18 parameters with inconsistent naming conventions
- **Modularization**: Single monolithic template
- **Environment Handling**: Uses both pEnv and pTaskEnv parameters

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires:
  - Decomposing IAM policies
  - Refactoring parameter management
  - Adding missing VPC endpoint configurations
  - Handling SSM parameter references

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Lambda function
   - IAM roles
   - Security groups
   - EventBridge rules
2. Migrate parameters to Terraform variables with validation
3. Implement least-privilege IAM policies
4. Add VPC endpoint resources
5. Validate with `terraform plan` before deployment

