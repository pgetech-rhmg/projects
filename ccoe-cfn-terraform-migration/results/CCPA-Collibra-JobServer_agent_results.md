# Repository Assessment: CCPA-Collibra-JobServer

## 1. Overview
Provisions Collibra JobServer EC2 instance with 16vCPU, 64GB RAM, and 500GB SSD. Includes IAM role, security group, and tagging for CCPA compliance.

## 2. Architecture Summary
Single-tier architecture using:
- EC2 instance (m4.4xlarge) with SSM access
- Custom IAM role with broad permissions
- Security group with internal-only ingress but open egress
- EBS volume with default encryption

## 3. Identified Resources
- AWS::IAM::Role (CCPACollibraJobServerRole)
- AWS::IAM::InstanceProfile (CCPACollibraJobServerRole)
- AWS::EC2::SecurityGroup (CCPACollibraJobServerSecurityGroup)
- AWS::EC2::Instance (Collibra JobServer)

## 4. Issues & Risks
- **Security Group Egress**: Allows all outbound traffic (0.0.0.0/0) - violates least privilege
- **IAM Policy Over-Grant**: Uses AmazonS3FullAccess instead of scoped permissions
- **Hardcoded Policies**: ManagedPolicyArns directly in template reduces flexibility
- **Deprecated Instance Types**: m4.4xlarge is previous-generation hardware
- **No Encryption Parameters**: EBS encryption not explicitly configured
- **Missing VPC Endpoints**: Potential data transfer costs for S3/CloudWatch

## 5. Technical Debt
- **Parameter Sprawl**: 15 parameters with overlapping purposes
- **Hardcoded Values**: Default environment set to "Dev"
- **No Environment Separation**: Single template for all environments
- **No Lifecycle Controls**: No termination protection or backup policies

## 6. Terraform Migration Complexity
Moderate. Requires:
- Refactoring IAM policies into data sources
- Decomposing SG rules into variables
- Adding missing encryption parameters
- Handling legacy instance type mapping

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM (role + policies)
   - Security group
   - EC2 instance
2. Migrate parameters to variables.tf
3. Add explicit encryption controls
4. Validate against AWS provider v5.x
5. Implement environment-specific backends

