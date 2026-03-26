# Repository Assessment: cscoe-org-config-rules

## 1. Overview
The repository implements AWS Organization-level Config Rules using CloudFormation templates. It establishes:
- Prerequisites (S3 bucket, KMS key)
- Cross-account IAM roles for Lambda functions
- Managed AWS Config Rules (partially commented out)
- Custom Lambda-backed Config Rules for access key rotation and security group remediation

Targets multi-account environments with centralized security governance.

## 2. Architecture Summary
- **Core Services**: CloudFormation, IAM, KMS, S3, Lambda, AWS Config, SES
- **Patterns**:
  - Centralized security controls via AWS Organizations
  - Cross-account Lambda execution using IAM roles
  - Event-driven remediation via Config Rules + Lambda
  - SSE-KMS encryption for artifacts

## 3. Identified Resources
- IAM Roles (5 total)
- IAM Policies (3 inline)
- KMS Key + Alias
- S3 Bucket + BucketPolicy
- AWS::Config::OrganizationConfigRule (1 active managed, 2 custom)
- Lambda Functions (2 via SAM transform)
- Lambda Permissions (2)

## 4. Issues & Risks
- **Security**:
  - Overprivileged IAM role (AdministratorAccess in CFDeployerRole)
  - Wildcard resource policies ('*') in multiple IAM statements
  - Hardcoded account numbers (CyberSecurityAccount parameters)
  - Missing SCP enforcement verification
  - S3 bucket versioning disabled (deprecated property)

- **Operational**:
  - No environment separation (dev/prod)
  - Hardcoded Lambda ARNs in rule templates
  - Excessive commented-out code
  - Inconsistent parameter naming conventions

## 5. Technical Debt
- **Modularization**:
  - Single monolithic pre-reqs template
  - No nested stacks or modules
  - Repeated policy documents

- **Maintainability**:
  - Hardcoded values instead of SSM parameters
  - No tagging strategy
  - Outdated Lambda runtime (Python 3.7)
  - Missing CloudFormation guard rails (stack policies)

## 6. Terraform Migration Complexity
- **Challenges**:
  - SAM transform requires AWS provider lambda resources
  - Complex IAM policy documents need conversion
  - Cross-account references require careful state management
  - Mappings would become locals/variables

- **Clean Mappings**:
  - S3/KMS/IAM resources map directly
  - Config Rules require aws_config_organization_* resources
  - SAM Lambda would use aws_lambda_function

## 7. Recommended Migration Path
1. **Prerequisites**:
   - Establish Terraform CI/CD pipeline
   - Create Terraform remote state backend (S3+DynamoDB)

2. **Phase 1**:
   - Migrate S3/KMS/Core IAM to Terraform
   - Use locals for account numbers
   - Add environment variables

