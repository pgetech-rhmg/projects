# Repository Assessment: psps-viz-devops-infra

## 1. Overview
The repository contains CloudFormation templates for the PSPS Visualization project's infrastructure bootstrapping. It establishes foundational AWS resources including SSM parameters, KMS keys, VPC enhancements, S3 logging buckets, and Secrets Manager secrets. The templates follow a modular pattern with environment-specific configurations and standardized tagging.

## 2. Architecture Summary
- **Core Services**: SSM Parameter Store, KMS, VPC (security groups/endpoints), S3, Secrets Manager
- **Patterns**:
  - Centralized configuration management via SSM
  - Environment-specific parameter resolution
  - Security-first approach with HTTPS enforcement and KMS encryption
  - Service isolation using VPC endpoints
  - Standardized tagging for compliance

## 3. Identified Resources
- SSM Parameters (20+)
- KMS Keys (6) with aliases and policies
- S3 Bucket (logging) with strict access controls
- Secrets Manager Secrets (5)
- EC2 Security Group (1)
- VPC Endpoints (6) for AWS services

## 4. Issues & Risks
- **Security**:
  - S3 Endpoint uses Gateway type (legacy) instead of Interface
  - KMS key policies grant root access ("kms:*")
  - Hardcoded external account IDs in KMS policies
  - Missing egress rules in security group
  - FoundryToken secret has default value "test"
- **Configuration**:
  - Typo in parameter name: "Envirionment" → "Environment"
  - Inconsistent parameter resolution syntax (dynamic vs static SSM references)
  - Duplicate resource name "rAmplifyAccessPassword" in foundry-token.yml

## 5. Technical Debt
- **Modularity**:
  - Single security group handles multiple services
  - KMS key templates contain redundant policy boilerplate
  - Mixed static/dynamic SSM parameter references
- **Hardcoding**:
  - Explicit AWS account IDs in KMS policies
  - Fixed CIDR blocks in security group rules
- **Lifecycle**:
  - No deletion policies on most resources
  - Missing versioning on S3 bucket

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (SSM, KMS, S3)
- VPC endpoint configuration differences would require adjustment
- SSM parameter resolution syntax would need standardization
- KMS key policies would benefit from Terraform modules
- Secrets Manager integration is straightforward

## 7. Recommended Migration Path
1. **Preparation**:
   - Fix parameter typos and duplicate names
   - Standardize SSM parameter resolution syntax
   - Remove hardcoded values

2. **Core Infrastructure**:
   - Migrate SSM parameters first (00_ and 99_ files)
   - Create KMS module with policy templates
   - Migrate S3 logging bucket with proper dependencies

3. **Service Integration**:
   - Convert VPC resources (security groups/endpoints)
   - Migrate Secrets Manager secrets
   - Validate all ARN references

4. **Validation**:
   - Use Terraform plan/apply in dry-run mode
   - Verify resource counts and configurations
   - Check KMS key policies and S3 bucket permissions

