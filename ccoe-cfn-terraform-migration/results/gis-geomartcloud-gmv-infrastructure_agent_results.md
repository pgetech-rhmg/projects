# Repository Assessment: gis-geomartcloud-gmv-infrastructure

## 1. Overview
The repository contains CloudFormation templates for centralized configuration management and encryption infrastructure. Key components include SSM Parameter Store for application metadata and KMS key management with policy controls.

## 2. Architecture Summary
- Uses SSM Parameter Store for environment-specific application configuration
- Implements KMS key with broad administrative permissions
- Follows hierarchical tagging strategy for governance
- Designed for multi-environment deployment (dev/qa/prod)

## 3. Identified Resources
- SSM Parameters (productparameterstore.yml): 
  - Application metadata (app name, ID, owner, etc.)
- KMS Resources (kms.yml):
  - Customer Master Key with root/admin access
  - KMS Alias for environment abstraction
  - SSM Parameter to store KMS ARN

## 4. Issues & Risks
- **Security**: KMS key policy grants kms:* to root/admin - violates least privilege
- **Compliance**: Hardcoded email (s6gu@pge.com) in parameters
- **Consistency**: Parameter descriptions mismatch actual values (pAppID references "Security GroupID")
- **Disabled Policy**: Critical Lambda execution role permissions commented out

## 5. Technical Debt
- **Hardcoding**: Default values like "NoMCP" and "Information Technology"
- **Parameter Sprawl**: 15 parameters in kms.yml with many overlapping values
- **Modularization**: Single templates for both parameters and KMS - limits reusability
- **Environment Handling**: Uses literals instead of CloudFormation mappings

## 6. Terraform Migration Complexity
Low-Moderate. 
- SSM parameters map directly to aws_ssm_parameter
- KMS key/policy requires HCL conversion but no complex dependencies
- Would need refactoring for Terraform best practices

## 7. Recommended Migration Path
1. Convert SSM parameter templates first (productparameterstore.yml)
2. Create Terraform KMS module with policy files
3. Migrate environment variables to Terraform variables
4. Validate with CloudFormation drift detection
5. Incremental rollout using Terraform workspaces

