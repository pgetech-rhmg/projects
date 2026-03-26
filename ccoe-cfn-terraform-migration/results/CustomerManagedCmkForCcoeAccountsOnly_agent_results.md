# Repository Assessment: CustomerManagedCmkForCcoeAccountsOnly

## 1. Overview
Repository contains two CloudFormation templates for centralized KMS key management in AWS Control Tower environments. Creates shared CMKs for landing zones and service-specific keys with standardized tagging and policy patterns.

## 2. Architecture Summary
Implements customer-managed KMS keys with:
- Standardized tagging schema (AppID, Owner, CRIS, etc.)
- Cross-account access controls using AWS Organizations paths
- Service integration via SSM Parameter Store
- Key rotation enabled by default

## 3. Identified Resources
- AWS::KMS::Key (2 instances)
- AWS::KMS::Alias (2 instances)
- AWS::SSM::Parameter (1 instance)

## 4. Issues & Risks
- **Critical Security Risk**: `Principal: "*"` in AllowRemoteAccountUseTheKey grants global access
- **Hardcoded Account ID**: Master account (739846873405) is hardcoded
- **Wildcard Actions**: kms:* permissions for root/SuperAdmin
- **Missing Environment Separation**: No dev/prod environment differentiation
- **Inconsistent Parameter Names**: pPgeEnv vs pEnv capitalization mismatch

## 5. Technical Debt
- **Parameter Sprawl**: Duplicated tagging parameters across templates
- **Hardcoded SSM Paths**: Defaults like "/general/appid" are hardcoded
- **No Lifecycle Management**: No retention policies or scheduled deletion
- **Tight Coupling**: ServiceKey template depends on SSM Parameter Store

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings for KMS and SSM resources
- Requires policy refactoring for security
- Need to standardize parameter names
- Would benefit from module decomposition

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - KMS key with policy
   - SSM parameter storage
   - Tagging schema
2. Migrate landing zone stack first
3. Parameterize hardcoded values
4. Implement environment-specific backends
5. Validate with aws_iam_policy_document data source

