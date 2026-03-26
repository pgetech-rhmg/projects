# Repository Assessment: cscoe-wiz-kiosk

## 1. Overview
The repository contains CloudFormation templates for deploying Wiz security integration across AWS environments. It includes:
1. Main connector stack with IAM roles and conditional policies
2. StackSet for organization-wide deployment
3. Secrets management for EKS and generic Wiz credentials

## 2. Architecture Summary
- **Core Pattern**: Centralized IAM role with feature-gated permissions for Wiz security scanning
- **Key Services**: IAM (roles/policies), CloudFormation StackSets, Secrets Manager, KMS
- **Deployment Model**: Supports both single-account and AWS Organizations deployment
- **Security Features**: Conditional policy attachments based on feature flags, resource tagging for access control

## 3. Identified Resources
- IAM Roles: WizAccess-Role, shared-wiz-role, shared-eks-wiz-role
- IAM Policies: 7 conditional managed policies + 2 inline policies
- Secrets Manager: 2 secrets (shared-wiz-access, shared-eks-wiz-access)
- CloudFormation StackSet: For org-wide deployment

## 4. Issues & Risks
- **Overly Permissive Policies**: WizFullPolicy contains 200+ read actions on all resources
- **Hardcoded Resource Patterns**: LightsailScanningPolicy uses fixed volume ARN pattern
- **Secrets Exposure**: YAML files use NoEcho but still require parameter security
- **Missing Logging**: No CloudTrail/S3 logging configuration for IAM activity
- **StackSet Permissions**: Requires careful review of SERVICE_MANAGED permissions

## 5. Technical Debt
- **Parameter Sprawl**: 12 parameters in main template with inconsistent naming
- **Hardcoded Values**: YAML files use static KMS alias and secret names
- **Policy Duplication**: Similar KMS permissions in multiple policies
- **No Environment Separation**: Single template for all environments

## 6. Terraform Migration Complexity
- **Moderate Complexity**:
  - Clean mapping for IAM and Secrets Manager resources
  - Requires refactoring:
    - CloudFormation intrinsic functions to Terraform syntax
    - StackSet deployment model
    - Conditional resources using count/for_each

## 7. Recommended Migration Path
1. **Modularization**:
   - Create Terraform modules for: IAM roles, policies, secrets
   - Maintain feature flags as module variables

2. **State Management**:
   - Separate state files for core connector and org deployment
   - Use remote state backend (S3+DynamoDB)

3. **Incremental Migration**:
   - First migrate secrets management (low risk)
   - Then IAM roles and policies
   - Finally StackSet configuration

4. **Security Enhancements**:
   - Add explicit deny statements in policies
   - Implement resource tagging standards
   - Add logging configuration during migration

