# Repository Assessment: ccoe-autopatch-parameters-cft

## 1. Overview
This repository contains a CloudFormation StackSet template designed to create standardized SSM Parameter Store entries for autopatch scheduling across multiple AWS accounts. It defines maintenance window suspension times, patch execution schedules, and notification endpoints.

## 2. Architecture Summary
The solution uses AWS Systems Manager Parameter Store as a centralized configuration store for autopatching. It follows a hierarchical naming convention (/ccoe/target/...) and implements environment tagging for some parameters. The architecture pattern is simple configuration management with no compute or networking resources.

## 3. Identified Resources
- AWS::SSM::Parameter (5 instances)
  - /ccoe/target/group-1-asg-suspend-mw
  - /ccoe/target/group-2-asg-suspend-mw
  - /ccoe/target/group-1-run-patch
  - /ccoe/target/group-2-run-patch
  - /ccoe/target/notification/endpoints

## 4. Issues & Risks
- Missing Env parameter declaration (referenced in Tags but not defined)
- Hardcoded email addresses in notification parameter
- No encryption configuration for sensitive values
- Inconsistent tagging implementation (only 3/5 parameters tagged)
- Potential security risk with public email domains in notification parameter

## 5. Technical Debt
- Parameter duplication (similar structure for group-1/group-2)
- No parameter validation for cron expressions
- No versioning or history tracking for parameter changes
- Lack of modularization (all parameters in single template)

## 6. Terraform Migration Complexity
Low - All resources map directly to Terraform's aws_ssm_parameter resource. Would require:
- Adding missing Env parameter
- Converting !Ref syntax to Terraform interpolation
- Refactoring to use locals/variables

## 7. Recommended Migration Path
1. Create Terraform module for SSM parameters
2. Migrate notification parameter first (simplest)
3. Implement parameter grouping with for_each
4. Add validation regex for cron values
5. Maintain existing parameter names during transition

