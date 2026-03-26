# Repository Assessment: eweb-backup-get-apis

## 1. Overview
The repository contains a SAM template for eweb-backup-get-apis with four primary API endpoints backed by Lambda functions. Includes dependency layer management, IAM roles, and comprehensive monitoring. Test stubs validate external dependency synchronization between package.json and SAM templates.

## 2. Architecture Summary
- **Core Services**: API Gateway (private endpoint), Lambda (Node.js 22.x), OpenSearch Serverless, RDS MySQL, Secrets Manager
- **Patterns**:
  - Serverless microservices architecture
  - Centralized dependency management via Lambda Layers
  - Environment-driven configuration through SSM parameters
  - Security controls using VPC endpoints and IAM least privilege
  - Observability through X-Ray tracing and CloudWatch alarms

## 3. Identified Resources
- 1x API Gateway (private endpoint)
- 4x Lambda Functions (address-lookup, outage-lookup, psps-forecast, favicon)
- 1x Lambda Layer (Node.js dependencies)
- 1x OpenSearch Access Policy
- 12x CloudWatch Alarms
- 4x CloudWatch Anomaly Detectors
- 4x IAM Roles with inline policies

## 4. Issues & Risks
- **Overly Permissive IAM**: Lambda functions have wildcard resource permissions (kms:*, aoss:*)
- **Missing Stage Parameter**: pStageName hardcoded in multiple resources
- **Inconsistent Dependency Management**: Test stubs show missing/extra dependencies in External lists
- **Security Exposure**: API Gateway policy allows PUT method not implemented in any function
- **Unused CORS Configuration**: Commented-out CORS settings might indicate incomplete security implementation

## 5. Technical Debt
- **Hardcoded Values**: 15-second timeout and 15,000ms latency thresholds
- **Tight Coupling**: Lambda functions directly reference database secrets ARN
- **Poor Modularization**: Single template handles all resources without nested stacks
- **Inconsistent Build Configuration**: Test stubs show variations in BuildProperties formatting

## 6. Terraform Migration Complexity
Moderate complexity due to:
- SAM-specific constructs (Globals, Metadata) needing manual conversion
- Lambda function configuration requiring explicit Terraform resource mapping
- Complex IAM policy documents needing HCL translation
- Anomaly detectors requiring AWS-specific metric expressions

## 7. Recommended Migration Path
1. **Dependency Layer**: Convert first as standalone module
2. **IAM Roles**: Create reusable role modules with policy attachments
3. **API Gateway**: Migrate using aws_apigatewayv2 resources
4. **Lambda Functions**: Convert with explicit environment variables and VPC config
5. **Monitoring**: Use Terraform CloudWatch provider for alarms/detectors
6. **Incremental Migration**: Deploy non-critical alarms first, then functions behind feature flags

