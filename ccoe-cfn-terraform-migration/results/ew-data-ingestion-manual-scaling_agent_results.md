# Repository Assessment: ew-data-ingestion-manual-scaling

## 1. Overview
The repository contains CloudFormation templates for manual scaling infrastructure of an Elasticsearch cluster in the Emergency Web (EW) data services environment. Key components include a Lambda Layer for Python dependencies and a Lambda function for scaling operations.

## 2. Architecture Summary
- **Lambda Layer**: Centralized Python library management for ingestion services
- **Lambda Function**: Manual scaling logic for Elasticsearch clusters
- **IAM Role**: Overly permissive execution role for Lambda
- **SSM Parameters**: Configuration management through Parameter Store

## 3. Identified Resources
- AWS::Lambda::LayerVersion (1)
- AWS::SSM::Parameter (3)
- AWS::Lambda::Function (1)
- AWS::IAM::Role (1)

## 4. Issues & Risks
- **Security**: 
  - Lambda execution role uses `Resource: "*"` for 6 services (ssm, cloudwatch, es, sns, kms, ec2)
  - Missing explicit encryption configuration for SSM parameters
  - No VPC endpoint policies shown
- **Configuration**:
  - Hardcoded Lambda timeout (900s) instead of parameterized value
  - Deprecated `AWS::SSM::Parameter::Value` syntax
  - Unused parameters (pTargetCount)
- **Reliability**:
  - No dead-letter queue configuration for potential failures
  - No explicit error handling in Lambda configuration

## 5. Technical Debt
- **Modularization**:
  - Single Lambda function handles both scaling directions
  - No separation between core logic and infrastructure
- **Hardcoding**:
  - Timeout value (900) and VPC subnet references
  - Compliance tags use SSM parameter paths instead of values
- **Maintainability**:
  - Verbose IAM policy statements
  - No versioning strategy for Lambda deployments

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for Lambda, IAM, and SSM resources
- Would require:
  - Refactoring SSM parameter references to modern syntax
  - Decomposing IAM policy into data blocks
  - Adding missing encryption configurations
  - Parameterizing hardcoded values

## 7. Recommended Migration Path
1. Convert Lambda Layer to Terraform module
2. Migrate SSM parameters using `aws_ssm_parameter`
3. Create IAM role with `aws_iam_role` and policy attachments
4. Implement Lambda function with VPC config
5. Validate parameter resolution differences between CFN and Terraform

