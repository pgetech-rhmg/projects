# Repository Assessment: oih-cfn-ec2

## 1. Overview
This CloudFormation template provisions two high-availability Microsoft SQL Server instances across two Availability Zones in a VPC. It uses Systems Manager Parameter Store for configuration values and includes detailed EBS volume configuration for SQL workloads.

## 2. Architecture Summary
- **Core Pattern**: Multi-AZ SQL Server deployment
- **Primary Services**: EC2, IAM, EBS, VPC
- **Key Features**:
  - 2x EC2 instances in separate private subnets
  - 5x EBS volumes per instance (OS + 4x data/log drives)
  - Dedicated security group with SQL-specific ports
  - Managed IAM policies for SSM and CloudWatch
  - Parameterization of all critical configuration values

## 3. Identified Resources
- 1x IAM Role (SQLServerEC2Role)
- 1x IAM Instance Profile (SQLServerInstanceProfile)
- 1x Security Group (SQLServerSecurityGroup)
- 1x Security Group Rule (SQLServerSGSelfReference)
- 2x EC2 Instances (SQLServer1, SQLServer2)
- 10x EBS Volumes (implicit through BlockDeviceMappings)

## 4. Issues & Risks
- **Security**:
  - Hard-coded RDP CIDR (10.0.0.0/8) in security group
  - SQL port 1433 open to entire VPC (10.0.0.0/8)
  - Compliance tag set to "None"
  - Missing encryption key specification (defaults to AWS-managed)
- **Configuration**:
  - No auto-recovery configuration for EC2 instances
  - No explicit KMS key management for EBS encryption
  - Environment hard-coded as "Dev" in tags
- **Best Practices**:
  - Missing CloudWatch Logs configuration
  - No backup solution defined for EBS volumes
  - No load balancer/failover mechanism

## 5. Technical Debt
- **Hard-coded Values**: Environment tags, notification emails
- **Parameter Sprawl**: 19 parameters for storage configuration
- **Modularization**: Single template handles all components
- **Lifecycle Management**: No termination protection
- **Environment Separation**: Only dev environment configuration

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Requires decomposition into modules (network/security/compute)
- Parameter Store integration would use data sources
- Would need explicit depends_on for SG self-reference

## 7. Recommended Migration Path
1. Create VPC module (import existing VPC/subnets)
2. Migrate security groups as standalone module
3. Convert IAM role to Terraform with policy attachments
4. Implement EC2 instances with dynamic block handling
5. Add explicit KMS key resources
6. Validate all SSM parameter references

