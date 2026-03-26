# Repository Assessment: github-actions-python

## 1. Overview
The CloudFormation template provisions a Python Django web application environment consisting of an EC2 instance behind an Application Load Balancer (ALB). Includes security group configuration, IAM roles, and basic tagging.

## 2. Architecture Summary
- **Compute**: Single EC2 instance deployed in user-specified subnet
- **Networking**: Internal ALB with HTTPS listener (TLS 1.2)
- **Security**: Security group with overly permissive ingress rules
- **Storage**: Encrypted 20GB GP2 root volume
- **IAM**: Instance role with broad managed policies (S3/CW/SSM FullAccess)

## 3. Identified Resources
- AWS::EC2::SecurityGroup
- AWS::IAM::Role
- AWS::IAM::Policy
- AWS::IAM::InstanceProfile
- AWS::EC2::Instance
- AWS::ElasticLoadBalancingV2::TargetGroup
- AWS::ElasticLoadBalancingV2::Listener
- AWS::ElasticLoadBalancingV2::LoadBalancer

## 4. Issues & Risks
- **Security Group Exposure**: Allows HTTP/HTTPS from all RFC1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- **IAM Overprivilege**: Uses AmazonS3FullAccess/CloudWatchFullAccess instead of least-privilege policies
- **Missing ALB Logging**: S3 access log configuration commented out
- **Hardcoded CIDRs**: Security group rules use static IP ranges instead of VPC/subnet references
- **KMS Wildcard**: IAM policy allows KMS actions on all resources

## 5. Technical Debt
- **Parameter Sprawl**: 16 parameters with inconsistent naming conventions
- **Tight Coupling**: EC2 instance directly references security group and subnet IDs
- **No Environment Separation**: Single template for all environments (Dev-Prod)
- **Hardcoded Values**: Uses literals for health check paths and timeouts

## 6. Terraform Migration Complexity
Moderate. Requires:
1. Refactoring security group rules to use VPC self-references
2. Decomposing IAM policies into least-privilege statements
3. Modularizing into network/compute/security components
4. Converting SSM parameter references to Terraform data sources

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - VPC resources (security groups)
   - Compute (EC2 + IAM)
   - ALB configuration
2. Use Terraform data sources for AMI lookup
3. Migrate parameters to variables with validation
4. Implement state management per environment
5. Validate with `terraform plan` before deployment

