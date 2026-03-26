# Repository Assessment: gis-geomartcloud-dpv-fidelity-validator

## 1. Overview
Partial CloudFormation template implementing scheduled Lambda invocation with basic IAM permissions. Contains metadata parameters but lacks core infrastructure components like Lambda function definitions.

## 2. Architecture Summary
- **Event-Driven Scheduling**: Uses CloudWatch Events (EventBridge) to trigger Lambda functions quarterly
- **Security Model**: IAM role with overly permissive Lambda policy (lambda:*)
- **Missing Components**: Lambda function definitions, VPC configurations, and data storage resources

## 3. Identified Resources
- AWS::Events::Rule (rCloudwatchEvent)
- AWS::Lambda::Permission (PermissionForEventsToInvokeLambda)
- AWS::IAM::Role (rEventruleRole)
- AWS::IAM::Policy (RolePolicies with lambda:* permissions)

## 4. Issues & Risks
- **Security**: 
  - Overly permissive IAM policy (lambda:*) violates least privilege
  - Hardcoded AWS account ID in Lambda ARN reference
  - Missing encryption configuration for sensitive parameters
- **Configuration**:
  - Deprecated Python 3.7 runtime (end-of-support 2023-06-27)
  - Missing Lambda function timeout/memory configuration
  - No dead-letter queue configuration for failed invocations
- **Compliance**:
  - DataClassification parameter exists but isn't enforced
  - Compliance parameter has default "None" with no validation

## 5. Technical Debt
- **Hardcoded Values**: 
  - AWS region in Lambda ARN (us-west-2)
  - Default parameter values (e.g., "NoMCP")
- **Missing Modularization**:
  - All resources in single template
  - No nested stacks or parameter hierarchy
- **Environment Handling**:
  - Redundant pEnv and pTaskEnv parameters
  - No environment-specific resource naming conventions

## 6. Terraform Migration Complexity
Moderate. Key challenges:
- IAM policy decomposition required
- Need to add missing Lambda resources
- Parameter Store references would require AWS provider lookups
- EventBridge schedule syntax differs slightly

## 7. Recommended Migration Path
1. Create Terraform modules for:
   - IAM (roles/policies)
   - Lambda (functions + permissions)
   - EventBridge rules
2. Migrate parameters to Terraform variables with validation
3. Replace SSM parameter lookups with Terraform data sources
4. Implement missing Lambda function resources
5. Decompose IAM policy into principle of least privilege

