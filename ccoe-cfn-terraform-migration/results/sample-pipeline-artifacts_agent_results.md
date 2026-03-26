# Repository Assessment: sample-pipeline-artifacts

## 1. Overview
This repository contains three CloudFormation templates that provision:
1. EC2 instance with SSH access and S3 upload capabilities
2. IAM role for EC2 with S3 write permissions
3. Encrypted, non-public S3 bucket for CI/CD artifacts

## 2. Architecture Summary
The solution creates a basic CI/CD artifact storage pattern using:
- S3 bucket with encryption and public access restrictions
- EC2 instance in a hardcoded VPC/subnet
- IAM role with minimal S3 permissions
- SSM parameter for AMI management

## 3. Identified Resources
- AWS::IAM::InstanceProfile
- AWS::EC2::Instance
- AWS::EC2::SecurityGroup
- AWS::IAM::Role
- AWS::IAM::Policy
- AWS::S3::Bucket
- AWS::S3::BucketPolicy

## 4. Issues & Risks
- **Hardcoded VPC/Subnet IDs**: Creates environment coupling
- **Missing egress rules**: Security group only allows inbound SSH
- **Public S3 access blocked**: Good security practice
- **No S3 bucket logging**: Missing audit trail
- **EC2 metadata service access**: Potential SSRF vector
- **No resource tagging**: Violates AWS best practices

## 5. Technical Debt
- **Parameter sprawl**: S3BucketName repeated across templates
- **No environment separation**: Single configuration for all environments
- **Tight resource coupling**: EC2 depends on hardcoded VPC resources
- **No lifecycle management**: Manual cleanup required

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings for most resources
- Requires refactoring of:
  - Hardcoded values to variables
  - Cross-template dependencies
  - SSM parameter handling

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - S3 bucket
   - EC2 instance
   - IAM role
2. Migrate S3 bucket first as dependency
3. Implement Terraform remote state
4. Add environment variables
5. Migrate IAM role and EC2 instance
6. Validate with terraform plan

