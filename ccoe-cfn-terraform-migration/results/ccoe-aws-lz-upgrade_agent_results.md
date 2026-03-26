# Repository Assessment: ccoe-aws-lz-upgrade

## 1. Overview
The repository implements CI/CD infrastructure for three deployment patterns: blue-green, standalone EC2, and in-place EC2 updates. Uses CloudFormation for orchestration, Lambda for automation, and SSM Parameter Store for configuration management. Targets Windows Server environments with AMI update automation.

## 2. Architecture Summary
- **Blue-Green Deployment**: 
  - Dual ASGs (blue/green) with Launch Templates
  - ALB with weighted target groups
  - Lambda triggers on SSM parameter changes
  - Scheduled scaling policies
- **Standalone EC2**:
  - Single EC2 instance with ENI preservation
  - Lambda-driven AMI updates
  - Uses SSM for AMI IDs
- **In-Place EC2**:
  - ASG with single launch template
  - ALB with HTTPS listener
  - Lambda handles AMI updates
  - Scheduled scaling policies

## 3. Identified Resources
- IAM Roles (overly permissive)
- Lambda Functions (Python 3.7/3.8)
- EC2 Launch Templates
- Auto Scaling Groups
- ALB/ELB + Target Groups
- CloudWatch Events
- SSM Parameters
- EBS Volumes (encrypted)

## 4. Issues & Risks
- **Security**:
  - IAM roles have `Resource: "*"` permissions
  - Missing VPC endpoints
  - No explicit encryption keys specified
  - Public S3 bucket references
- **Reliability**:
  - Hardcoded timeouts (Lambda 900s)
  - No rollback mechanisms
  - Single-region deployment
- **Compliance**:
  - Uses deprecated python3.7 runtime
  - Missing data retention policies
  - Inconsistent tagging

## 5. Technical Debt
- **Modularity**:
  - Duplicated Lambda patterns across stacks
  - No nested stacks
  - Hardcoded parameter values
- **Maintainability**:
  - Mixed deployment strategies in one repo
  - Inconsistent resource naming
  - No version control on Lambda code
- **Scalability**:
  - Fixed subnet references
  - No dynamic scaling policies

## 6. Terraform Migration Complexity
- **Challenges**:
  - Complex IAM policy conversion
  - SSM parameter integration
  - ALB listener rule syntax differences
- **Readiness**: 60%
  - Requires:
    - IAM policy refactoring
    - Lambda environment variable mapping
    - ASG scheduled action conversion

## 7. Recommended Migration Path
1. **Preparation**:
   - Establish Terraform state backend
   - Create provider configuration
   - Define tagging standards

2. **Core Infrastructure**:
   - Migrate VPC/subnets (existing SSM references)
   - Convert IAM roles to least-privilege
   - Implement SSM parameter module

3. **Deployment Patterns**:
   - Standalone EC2 first (simplest)
   - Blue-green ASGs with target groups
   - In-place ASG last

4. **Lambda Functions**:
   - Use terraform-aws-lambda module
   - Parameterize environment variables

