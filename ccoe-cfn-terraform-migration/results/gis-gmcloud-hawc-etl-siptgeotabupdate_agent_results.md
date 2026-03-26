# Repository Assessment: gis-gmcloud-hawc-etl-siptgeotabupdate

## 1. Overview
Partial CloudFormation template for ETL pipeline component that updates geospatial data tables. Uses scheduled Lambda execution with EFS integration and CloudWatch monitoring.

## 2. Architecture Summary
- **Core Service**: AWS Lambda function triggered by EventBridge schedule
- **Data Flow**: Lambda → EFS (read/write) → External systems (via Secrets Manager/S3/RDS)
- **Security**: IAM roles with managed policies and inline permissions, KMS encryption
- **Observability**: CloudWatch Logs/Metrics and X-Ray tracing

## 3. Identified Resources
- IAM Roles (2): Lambda execution role + EventBridge invocation role
- Lambda Function: Python 3.7 runtime with VPC/EFS integration
- EventBridge Rule: 1-minute schedule trigger
- Lambda Permission: Allow EventBridge invocation
- IAM Policy: EventBridge role policy with lambda:* permissions

## 4. Issues & Risks
- **Overly Permissive Permissions**:
  - S3:* on all buckets (security risk)
  - KMS:Decrypt/Encrypt on all keys (potential data exposure)
  - SecretsManager:* on all secrets (credential risk)
  - Lambda:* in event role policy (excessive privileges)
- **Missing Resource Definitions**: VPC/subnets referenced but not defined
- **Deprecated Runtime**: Python 3.7 Lambda runtime (end-of-support 2023-06-27)
- **Hardcoded Values**: Lambda timeout (900s) and memory (1024MB) not parameterized
- **Inconsistent Environment Parameters**: pEnv vs pTaskEnv casing mismatch

## 5. Technical Debt
- **Inline Policies**: Makes IAM roles harder to manage and audit
- **Parameter Sprawl**: 20+ parameters with inconsistent naming conventions
- **Hardcoded Security Configurations**: KMS ARN and EFS ARN not environment-specific
- **Missing Lifecycle Controls**: No retention policies for logs/metrics

## 6. Terraform Migration Complexity
Moderate complexity:
- **Clean Mappings**: Lambda, IAM roles, EventBridge rules
- **Refactoring Needed**:
  - Convert inline policies to managed policies
  - Decompose monolithic IAM statements
  - Parameterize hardcoded values
  - Add missing VPC/subnet resources

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM (roles + policies)
   - Lambda function
   - EventBridge schedule
2. Migrate parameters to Terraform variables with validation
3. Replace SSM parameter lookups with Terraform data sources
4. Implement VPC/subnet definitions
5. Validate with `terraform plan` before deployment

