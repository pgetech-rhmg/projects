# Repository Assessment: ccoe-ami-test

## 1. Overview
The repository contains CloudFormation templates for automated EC2 AMI testing using AWS Lambda functions. It includes infrastructure for both Twistlock and generic AMI validation workflows, with supporting IAM roles and security configurations.

## 2. Architecture Summary
- **Core Components**: Lambda functions for AMI validation, EC2 instance provisioning, and security group management
- **Services Used**: Lambda, IAM, EC2, SSM Parameter Store, CloudWatch Events
- **Patterns**: Event-driven architecture (CloudWatch Events → Lambda), serverless compute, parameterized infrastructure

## 3. Identified Resources
- Lambda Functions (4 total)
- IAM Roles (2 with overly permissive policies)
- EC2 Instance (1)
- Security Group (1)
- SSM Parameter References (7)

## 4. Issues & Risks
- **Security**: 
  - Overly permissive IAM policies (ec2:*, kms:*, iam:*)
  - Hardcoded account ID in linux_ami_test.yaml
  - Public SSH access (CidrIp: 10.0.0.0/8)
  - Missing VPC flow logs
- **Configuration**:
  - Deprecated Python 3.7 runtime
  - Hardcoded S3 bucket names
  - Inconsistent tagging between templates
  - Missing error handling in Lambda functions

## 5. Technical Debt
- **Modularization**: Duplicated IAM role definitions
- **Hardcoding**: S3 bucket names and Lambda timeouts
- **Maintainability**: No environment-specific configurations
- **Compliance**: Inconsistent data classification tagging

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires:
  - IAM policy refactoring
  - Parameterization of hardcoded values
  - Module decomposition
  - Python runtime update

## 7. Recommended Migration Path
1. Establish Terraform environment structure
2. Migrate SSM parameters first
3. Create IAM module with least-privilege policies
4. Convert EC2 resources with dynamic references
5. Migrate Lambda functions with updated runtime
6. Implement environment-specific variables

