# Repository Assessment: cloudcoe-sagemaker

## 1. Overview
The repository contains CloudFormation templates for deploying SageMaker infrastructure with governance controls. Key components include service-linked roles, KMS encryption, Config compliance rules, and a SageMaker Notebook instance.

## 2. Architecture Summary
- **Governance**: Uses AWS Config service-linked role and custom compliance rules
- **Security**: KMS key for SageMaker encryption with role-based access
- **Compute**: SageMaker Notebook instance with encryption at rest
- **Compliance**: Lambda-backed Config rule to enforce SageMaker encryption

## 3. Identified Resources
- IAM::ServiceLinkedRole (AWS Config)
- IAM::ManagedPolicy (Lambda permissions)
- IAM::Role (Lambda execution + SageMaker service)
- Lambda::Function (Compliance validation)
- Config::ConfigRule (SageMaker encryption check)
- SageMaker::NotebookInstance (Encrypted development environment)
- KMS::Key (Encryption key)
- KMS::Alias (Friendly key name)

## 4. Issues & Risks
- **Security**:
  - Overly permissive S3 policy (s3:*) in Lambda managed policy
  - Wildcard principal in KMS key policy (allows all listed roles full access)
  - Hardcoded KMS key ID in SageMaker template (breaks environment isolation)
  - Missing VPC configuration for SageMaker Notebook (public internet exposure)
- **Best Practices**:
  - Deprecated DeletionPolicy:Retain in ServiceLinkedRole (use standard deletion)
  - No rotation configuration for KMS key (requires manual setup)
  - Missing CloudTrail integration for compliance tracking

## 5. Technical Debt
- **Modularity**:
  - No nested stacks or cross-stack references
  - Repeated PGE tagging parameters across templates
- **Hardcoding**:
  - Default KMS key ID ("Replace it...") in SageMaker template
  - Fixed instance type (ml.t2.medium) with no override
- **Maintainability**:
  - No version control metadata in templates
  - Inconsistent parameter naming conventions (pPge vs pNotebook)

## 6. Terraform Migration Complexity
Moderate complexity:
- ServiceLinkedRole requires special handling (Terraform aws_iam_service_linked_role)
- Lambda deployment packaging needed for local code
- KMS key rotation requires explicit state management
- Config rules have direct 1:1 mapping but need dependency ordering
- IAM policies would benefit from Terraform's policy documents

## 7. Recommended Migration Path
1. **Foundation**:
   - Create Terraform backend configuration (S3+DynamoDB)
   - Establish provider configuration with proper versioning

2. **Security First**:
   - Migrate KMS key using aws_kms_key with proper rotation
   - Convert service-linked role to aws_iam_service_linked_role

3. **Core Services**:
   - Implement SageMaker IAM role with aws_iam_role
   - Migrate Notebook instance with VPC configuration
   - Add missing SSM parameter for KMS key reference

4. **Governance**:
   - Convert Lambda policy to Terraform data sources
   - Migrate Lambda function with local file handling
   - Implement Config rule with explicit dependencies

