# Repository Assessment: emergency-website-aws-hosting-linux

## 1. Overview
This CloudFormation template provisions a single EC2 instance in a public subnet for Linux-based emergency website hosting. Uses SSM parameters for AMI selection and stores instance ID in SSM Parameter Store. Includes extensive bootstrapping via UserData script.

## 2. Architecture Summary
- Single EC2 instance in public subnet (security risk)
- Uses latest Amazon Linux 2 AMI via SSM parameter
- Installs SSM, Docker, AWS CLI, CodeDeploy, Inspector, and Twistlock agents
- Creates multiple local users with SSH access from Secrets Manager
- Exposes instance to internet via public subnet (requires security group validation)

## 3. Identified Resources
- AWS::EC2::Instance (t2.small)
- AWS::SSM::Parameter (for instance ID storage)
- Implicit dependencies: IAM Instance Profile, Security Group, Subnet, SSM Parameter Store

## 4. Issues & Risks
- **Security**: 
  - Public subnet exposure (requires validation of security group rules)
  - Hardcoded SSH key retrieval from Secrets Manager (region-locked)
  - NOPASSWD sudoers for all users (privilege escalation risk)
  - Missing encryption configuration for EBS volumes
- **Reliability**: 
  - Hardcoded us-west-2 region in SSM parameter reference
  - No VPC/subnet validation checks
  - UserData script failure would block stack creation
- **Compliance**: 
  - Uses deprecated amzn2-ami-hvm AMI family (should use AL2023)
  - Missing resource-level tagging for cost allocation

## 5. Technical Debt
- Hardcoded values: AMI path, region, GID ranges, user list
- UserData script contains business logic (should be externalized)
- No environment-specific parameter groups
- Missing VPC flow logs or network ACLs
- No instance termination protection

## 6. Terraform Migration Complexity
Moderate. Key challenges:
- SSM parameter references require aws_ssm_parameter data source
- UserData script would need conversion to Terraform templatefile
- IAM instance profile dependency needs explicit declaration
- Security group validation would require separate resource lookup

## 7. Recommended Migration Path
1. Create Terraform modules for: EC2 instance, SSM parameters, security groups
2. Migrate parameters to variables.tf with type validation
3. Convert UserData to templatefile with variable substitution
4. Add explicit VPC/subnet dependencies
5. Implement resource tagging standards
6. Validate security group rules through separate data sources

