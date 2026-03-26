# Repository Assessment: gis-geomartcloud-mab-ui

## 1. Overview
This CloudFormation template provisions static website infrastructure using S3 buckets and SSM parameters. It creates two buckets (website and asset repository) with referer-based access controls and stores configuration in Parameter Store.

## 2. Architecture Summary
- **Core Services**: S3 (buckets + policies), SSM Parameter Store
- **Pattern**: Static website hosting with centralized configuration management
- **Security**: Referer-based access control (CloudFront integration implied)

## 3. Identified Resources
- 2x S3::Bucket
- 2x S3::BucketPolicy
- 2x SSM::Parameter

## 4. Issues & Risks
- **Security**:
  - Public read access via referer condition (risk of improper configuration)
  - Missing bucket encryption (S3 Block Public Access not enforced)
  - No logging configuration for access monitoring
- **Configuration**:
  - Parameter name mismatch (pReferer vs pRefererValue)
  - Hardcoded SSM parameter paths ("/general/...")
  - Duplicated tag definitions across resources
- **Compliance**:
  - DataClassification parameter exists but not used in bucket policies
  - Compliance parameter not enforced in resource configurations

## 5. Technical Debt
- **Modularity**: Single template handles both buckets and parameters
- **Hardcoding**: SSM parameter names use fixed paths instead of environment variables
- **Parameter Sprawl**: 18 parameters with overlapping purposes
- **Missing Features**: No versioning/lifecycle policies for buckets

## 6. Terraform Migration Complexity
Moderate. Requires:
- Refactoring SSM parameter paths to use variables
- Decomposing into modules (buckets, policies, parameters)
- Handling parameter name mismatches
- Adding missing security controls during migration

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - S3 buckets with standardized tagging
   - Bucket policies with conditional logic
   - SSM parameters with variable-based naming
2. Migrate parameters first to establish configuration store
3. Implement buckets with proper encryption/logging
4. Validate referer policies against CloudFront distribution
5. Incremental rollout using Terraform workspaces

