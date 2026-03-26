# Repository Assessment: eweb-auth-lambda

## 1. Overview
The repository contains a CloudFormation template implementing an authentication service using AWS Lambda, API Gateway, and CloudWatch monitoring. It includes multiple Lambda functions for OAuth workflows, outage data lookups, and utility endpoints. The infrastructure uses VPC networking, Lambda layers for code reuse, and SSM parameters for configuration management.

## 2. Architecture Summary
- **Core Services**: API Gateway (HTTP endpoints), Lambda (business logic), CloudWatch (monitoring), SSM (configuration)
- **Patterns**:
  - Serverless microservices architecture
  - Lambda@Edge for SSO integration
  - VPC-enabled Lambda functions with shared security groups
  - Environment-based configuration through SSM parameters
  - Extensive observability with alarms and anomaly detection

## 3. Identified Resources
- 1x API Gateway REST API
- 12x Lambda functions (Node.js 22.x)
- 4x Lambda layers
- 13x IAM Roles
- 20x CloudWatch Alarms
- 10x CloudWatch Anomaly Detectors
- 4x SSM Parameters

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM roles with `Resource: "*"` for KMS/SecretsManager
  - Missing WAF integration on API Gateway
  - Hardcoded S3 bucket names in IAM policies
  - Public access not explicitly restricted (though IP whitelisting exists)
- **Configuration**:
  - Hardcoded values for environment variables (e.g., `pMainUrl`)
  - Missing environment variables for some functions
  - Potential SSM parameter limit issues (workaround mentioned)
- **Reliability**:
  - No dead-letter queue configuration for async workflows
  - Missing retry policies on Lambda functions

## 5. Technical Debt
- **Modularity**:
  - Repeated IAM policy structures across roles
  - Lambda environment variables duplicated across functions
  - No nested stacks or modules
- **Maintainability**:
  - Parameter sprawl with 19 SSM parameters
  - Hardcoded ARNs for commercial Lambda layers
  - Inconsistent tagging implementation
- **Lifecycle Management**:
  - No deployment strategies defined (blue/green)
  - Missing versioning for Lambda layers

## 6. Terraform Migration Complexity
- **High Compatibility**:
  - API Gateway, Lambda, IAM, and CloudWatch map cleanly
  - SSM parameters translate directly to `aws_ssm_parameter`
- **Required Refactoring**:
  - Decompose IAM roles into reusable modules
  - Convert Lambda layers to Terraform registry
  - Parameterize hardcoded values
  - Add missing Terraform-specific features (e.g., `ignore_changes`)

## 7. Recommended Migration Path
1. **Preparation**:
   - Create Terraform state backend (S3+DynamoDB)
   - Establish module structure: `networking/`, `lambda/`, `monitoring/`

2. **Core Infrastructure**:
   - Migrate VPC configuration (if not existing)
   - Convert API Gateway resources
   - Create base IAM roles with least privilege

3. **Lambda Functions**:
   - Migrate individual functions with VPC config
   - Replace SSM parameter references with Terraform variables
   - Implement deployment packages with `archive_file`

