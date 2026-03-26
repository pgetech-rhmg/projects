# Repository Assessment: cscoe-cloudknox

## 1. Overview
The repository contains CloudFormation templates for deploying CloudKnox security monitoring infrastructure across AWS Organizations. Key components include cross-account IAM roles for centralized logging, organization visibility, and member account auditing, plus an EC2-based Sentry appliance for data collection.

## 2. Architecture Summary
Implements a multi-account security monitoring solution using:
- Cross-account IAM roles for organization-wide visibility
- Dedicated logging account role for CloudTrail access
- EC2-based Sentry collector with autoscaling in member VPCs
- SSM integration for configuration management
- Hardcoded trust relationships between accounts

## 3. Identified Resources
- IAM Roles (5 total)
- IAM Instance Profile
- AutoScaling Launch Configuration
- AutoScaling Group
- Security Group (conditional)
- AMI mappings for 4 regions

## 4. Issues & Risks
- **Hardcoded Account IDs**: Uses explicit 686137062481 in all trust policies
- **Wildcard Resource Policies**: Multiple "*" resources in IAM policies
- **Missing Encryption**: S3 bucket ARNs lack encryption requirements
- **No Environment Separation**: Single configuration for all deployments
- **Broad Management Permissions**: Member roles allow IAM policy creation/deletion

## 5. Technical Debt
- **Parameter Sprawl**: 6 parameters with overlapping purposes
- **Hardcoded Values**: AMI IDs, PoseidonURL, region lists
- **Tight Coupling**: Cross-account dependencies via hardcoded ARNs
- **No Lifecycle Management**: ASG has static DesiredCapacity=5

## 6. Terraform Migration Complexity
Moderate. Key challenges:
- Conditional resources require refactoring
- IAM policy documents need HCL conversion
- AMI mappings become data structures
- AutoScaling configuration differs slightly between CFN/TF

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - Cross-account roles (Master/Member/Logging variants)
   - Sentry infrastructure (EC2/ASG/IAM)
2. Use data sources for AMI lookups
3. Migrate logging account first
4. Implement parameter validation
5. Add environment tagging

