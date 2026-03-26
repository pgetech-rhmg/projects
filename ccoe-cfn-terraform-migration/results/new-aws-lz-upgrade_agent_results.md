# Repository Assessment: new-aws-lz-upgrade

## 1. Overview
The repository contains CloudFormation templates implementing three distinct EC2 AMI update patterns:  
1. Blue-Green Deployment (bg-cft/)  
2. Standalone EC2 Instance Update (standalone-EC2-ami-update-cft/)  
3. In-Place EC2 Update (inplace-EC2-ami-update-cft/)  

All patterns use Lambda functions for automation and SSM Parameter Store for configuration management. The templates include infrastructure for ALB/ELB, Auto Scaling Groups, Launch Templates, and EC2 instances.

## 2. Architecture Summary
- **Blue-Green**: Uses two ASGs (blue/green) with weighted target groups for zero-downtime deployments  
- **Standalone EC2**: Single EC2 instance replacement with ENI preservation  
- **In-Place Update**: ASG with rolling updates using Launch Template versioning  

Core services:  
- EC2 (instances, ASG, Launch Templates)  
- Elastic Load Balancing (ALB/ELB)  
- Lambda  
- IAM Roles  
- SSM Parameter Store  
- CloudWatch Logs (implicit via Lambda)

## 3. Identified Resources
- IAM Roles (overly permissive policies)  
- Lambda Functions (Python 3.7/3.8)  
- EC2 Launch Templates  
- Auto Scaling Groups  
- ALB/ELB Target Groups  
- SSM Parameters  
- CloudWatch Log Groups (implicit)  
- Security Groups (referenced via SSM)

## 4. Issues & Risks
- **Security**:  
  - Overly permissive IAM policies (`ec2:*`, `kms:*`, `cloudformation:*`)  
  - Missing VPC flow logs  
  - Hardcoded Lambda timeout (900s)  
  - Publicly exposed Lambda functions (no VPC config)  
  - No encryption at rest specified for Lambda  

- **Configuration**:  
  - Hardcoded Lambda runtime versions (python3.7/3.8)  
  - Instance storage constraint mismatch (description vs. MinValue)  
  - Missing health check configuration for standalone EC2  
  - Inconsistent parameter naming conventions  

- **Resilience**:  
  - Single-AZ Lambda deployment (no subnet configuration)  
  - No explicit ASG termination policies  
  - No Lambda error handling for critical operations

## 5. Technical Debt
- **Modularity**:  
  - High parameter duplication across templates  
  - No nested stacks or cross-stack references  
  - Lambda code duplication between patterns  

- **Maintainability**:  
  - Hardcoded values in Lambda code (AMI paths, SSM keys)  
  - No versioning for Lambda deployment packages  
  - Inconsistent resource naming conventions  

- **Environment Management**:  
  - No environment-specific parameters  
  - Mixed DEV/PROD configurations in defaults  
  - No lifecycle management for old Launch Template versions

## 6. Terraform Migration Complexity
- **Moderate Complexity**:  
  - Clean 1:1 mappings exist for most resources (ASG, LT, ALB)  
  - Requires decomposition of Lambda I

## 7. Recommended Migration Path
Not Observed

