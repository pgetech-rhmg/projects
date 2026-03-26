# Repository Assessment: cscoe-config-rules

## 1. Overview
The repository implements AWS Config compliance monitoring across multiple services using Lambda-backed custom rules. Key features include:
- Cross-account compliance validation
- Service-specific tagging/encryption enforcement
- Centralized logging and artifact management
- Multi-account deployment via StackSets
- Integration with Brinqa ticketing system

## 2. Architecture Summary
- **Core Pattern**: Service-specific compliance validation using AWS Config + Lambda
- **Primary Services**: Config, Lambda, IAM, KMS, S3, DynamoDB, EventBridge, VPC
- **Security Model**:
  - VPC-isolated Lambda functions with private endpoints
  - KMS encryption for sensitive data
  - Cross-account IAM roles with least-privilege policies
- **Deployment**: StackSets for multi-account rollouts

## 3. Identified Resources
- Lambda Functions (200+)
- IAM Roles/Policies (200+)
- Config Rules (150+)
- S3 Buckets (multiple)
- KMS Keys (centralized)
- DynamoDB Tables (compliance tracking)
- EventBridge Rules (event routing)
- VPC Endpoints (private connectivity)
- SSM Parameters (configuration)

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (Resource:"*")
  - Hardcoded ARNs/Account IDs
  - Wildcard principals in S3 policies
  - Missing KMS permissions (GenerateDataKeyWithoutPlaintext)
  - Public S3 access in some policies
- **Reliability**:
  - Python 3.7 Lambda runtime (EOL 2024)
  - Missing dead-letter queues
  - Open VPC egress rules
- **Compliance**:
  - Missing logging configurations
  - Inconsistent tagging
  - Deprecated CloudFormation metadata

## 5. Technical Debt
- **Modularization**: Monolithic templates with repeated patterns
- **Hardcoded Values**: Fixed bucket names, ORG paths, and retry counts
- **Parameter Sprawl**: Redundant parameters across templates
- **Tight Coupling**: Lambda functions reference SSM parameters directly
- **Maintainability**: Inconsistent parameter naming and missing outputs

## 6. Terraform Migration Complexity
Moderate to High due to:
- Complex IAM policy documents
- SSM parameter references requiring conversion
- Lambda deployment model differences
- Config Rule dependency management
- Cross-account resource handling

## 7. Recommended Migration Path
1. Establish Terraform state management (S3+DynamoDB)
2. Migrate foundational resources (KMS, S3, VPC endpoints)
3. Create service-specific Terraform modules
4. Refactor IAM policies into reusable HCL
5. Convert Lambda functions with zipfile deployment
6. Replace SSM parameters with data sources
7. Validate through incremental service migration

