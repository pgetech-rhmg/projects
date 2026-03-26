# Repository Assessment: gis-geomartcloud-pspsv4-infrastructure

## 1. Overview
The repository contains CloudFormation templates for deploying ArcGIS Pro infrastructure in AWS. It includes prerequisites (Lambda/SSM automation), EC2 instance provisioning, and Secrets Manager configuration. The solution automates ArcGIS Pro installation on Windows EC2 instances launched from a golden AMI.

## 2. Architecture Summary
- **Automation**: Uses CloudWatch Events, Lambda, and SSM Automation Documents to trigger ArcGIS Pro installation after EC2 first boot
- **Compute**: Deploys Windows EC2 instances with configurable instance types and security groups
- **Storage**: EBS volumes with KMS encryption
- **Security**: IAM roles for Lambda, parameter store integration, and SSM secrets (partially implemented)
- **Networking**: Depends on existing VPC configuration (security groups/subnets from SSM parameters)

## 3. Identified Resources
- AWS::Events::Rule
- AWS::Lambda::Function
- AWS::Lambda::Permission
- AWS::Logs::LogGroup
- AWS::IAM::Role
- AWS::IAM::Policy
- AWS::SSM::Document
- AWS::EC2::Instance (x3)
- AWS::SecretsManager::Secret (partially implemented)

## 4. Issues & Risks
- **Security**:
  - Hardcoded S3 bucket name ("geomartcloud-psps-data-dev") violates least privilege
  - Lambda policy uses wildcard resources ("arn:aws:ec2:*:*:instance/*")
  - Missing VPC endpoint configurations for SSM/S3
  - Python 3.6 Lambda runtime is deprecated
  - Secrets Manager secrets commented out in final template
- **Configuration**:
  - Lambda timeout set to 60s (may be insufficient for complex installs)
  - No explicit CloudWatch logging configuration for EC2
  - SSM document uses fixed ArcGIS Pro version (2.5.1)
- **Reliability**:
  - Single Lambda function handles all automation logic
  - No error handling for S3 object copies

## 5. Technical Debt
- **Hardcoding**: S3 bucket names and SSM document versions
- **Modularity**: Single Lambda function contains all business logic
- **Versioning**: Uses manual StackVersion parameter instead of Git-based versioning
- **Environment Separation**: No clear environment-specific configurations
- **Lifecycle Management**: No termination protection or update policies

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (Lambda, IAM, EC2)
- SSM Documents would require conversion to Terraform's JSON syntax
- Secrets Manager has straightforward HCL equivalent
- Would need to refactor:
  - Hardcoded values into variables
  - SSM document content into file-based storage
  - Python Lambda handler into deployment package

## 7. Recommended Migration Path
1. Establish Terraform state backend (S3+DynamoDB)
2. Migrate parameter store values to Terraform variables
3. Convert IAM roles/policies first
4. Migrate Lambda function (create deployment package)
5. Translate SSM documents to Terraform JSON
6. Implement EC2 instances with existing security groups
7. Add Secrets Manager resources
8. Validate all resources before decommissioning CloudFormation

