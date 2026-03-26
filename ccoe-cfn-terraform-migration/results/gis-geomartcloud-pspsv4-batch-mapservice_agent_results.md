# Repository Assessment: gis-geomartcloud-pspsv4-batch-mapservice

## 1. Overview
Partial CloudFormation template for PSPS Batch Map Service infrastructure. Focuses on IAM roles, security groups, and Lambda function configuration.

## 2. Architecture Summary
Deploys a Lambda function with VPC connectivity and broad AWS service permissions. Uses SSM parameters for configuration and security group for network isolation.

## 3. Identified Resources
- IAM Role (psps-batch-mapservice-lambdarole)
- EC2 Security Group (psps-batch-mapservice)
- Security Group Ingress Rule
- Lambda Function (psps-batch-mapservice)

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies (multiple "Resource: *" statements)
- **Compliance**: Uses deprecated Python 3.7 runtime
- **Configuration**: Duplicate parameters (pEnv/pTaskEnv, pVpcId/pVPCID)
- **Hardcoding**: Lambda layer ARN references us-west-2 region
- **Missing Resources**: No S3 bucket definitions despite S3 permissions

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with redundancy
- **Hardcoded Values**: Security group name and Lambda timeout
- **Modularization**: Single monolithic template structure
- **Environment Handling**: Mixed case environment parameters (pEnv vs pTaskEnv)

## 6. Terraform Migration Complexity
Moderate. Requires:
- Refactoring IAM policies into data structures
- Handling SSM parameter lookups
- Decomposing into Terraform modules
- Addressing hardcoded region values

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM (role + policies)
   - Security groups
   - Lambda function
2. Migrate parameters to Terraform variables
3. Replace SSM parameter lookups with Terraform data sources
4. Validate VPC/subnet references
5. Implement gradual rollout using Terraform workspaces

