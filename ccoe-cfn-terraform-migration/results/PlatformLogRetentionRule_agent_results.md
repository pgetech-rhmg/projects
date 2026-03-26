# Repository Assessment: PlatformLogRetentionRule

## 1. Overview
This CloudFormation StackSet template deploys an EventBridge rule ("LogRetention") that triggers when new CloudWatch Log Groups are created, sending events to a specified EventBridge bus. Designed for multi-account/region deployment via StackSets.

## 2. Architecture Summary
Uses EventBridge pattern to detect CloudWatch Log Group creation events and propagate them to a centralized event bus. Includes minimal IAM role for cross-service permissions.

## 3. Identified Resources
- AWS::Events::Rule (LogRetentionRule)
- AWS::IAM::Role (EventBridgeIAMrole) with inline policy

## 4. Issues & Risks
- **Security Risk**: Hardcoded account ID (686137062481) in EventBusArn parameter default creates cross-account dependency
- **Configuration Gap**: No DependsOn between LogRetentionRule and EventBridgeIAMrole
- **Missing Permissions**: IAM role lacks logs:PutRetentionPolicy permission required for actual retention enforcement
- **Region Limitation**: EventBus ARN hardcoded to us-west-2 - incompatible with StackSet multi-region deployments

## 5. Technical Debt
- **Hardcoded Values**: Default EventBusArn contains static account ID
- **Parameter Sprawl**: Only one parameter exists - missing configuration for retention period
- **No Environment Separation**: No environment-specific configurations or tagging
- **No Lifecycle Management**: No retention policies on IAM role or EventBridge artifacts

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for Events::Rule and IAM::Role
- Requires refactoring of:
  - Hardcoded ARNs to data sources
  - StackSet parameters to Terraform variables
  - Missing DependsOn to explicit dependencies

## 7. Recommended Migration Path
1. Create Terraform module structure (main.tf, variables.tf, outputs.tf)
2. Migrate IAM role first with proper dependency handling
3. Convert EventBridge rule using Terraform aws_cloudwatch_event_rule
4. Replace hardcoded ARN with aws_caller_identity data source
5. Add missing logs:PutRetentionPolicy to IAM policy
6. Validate with terraform plan against target accounts

