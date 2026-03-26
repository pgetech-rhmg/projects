# Repository Assessment: psps-viz-lambda

## 1. Overview
The repository contains a CloudFormation template implementing a serverless API solution for address visualization lookups. Uses AWS SAM with private API Gateway endpoints, Lambda functions, custom layers, and IAM roles.

## 2. Architecture Summary
- **API Gateway**: Private REST API with VPC endpoint integration
- **Lambda Functions**: Four Node.js functions for address/area lookups
- **Custom Layers**: Dependency management and origin validation
- **IAM**: Overly permissive roles with wildcard resource access
- **SSM**: Stores API metadata for cross-stack references

## 3. Identified Resources
- AWS::Serverless::Api (1)
- AWS::Serverless::Function (4)
- AWS::Serverless::LayerVersion (2)
- AWS::IAM::Role (4)
- AWS::SSM::Parameter (2)

## 4. Issues & Risks
- **Security**:
  - IAM roles use `Resource: "*"` for all permissions (ec2, es, logs, kms)
  - Hardcoded Dynatrace tokens in environment variables
  - Missing VPC security group configuration
  - Public CORS configuration commented out but still present
- **Configuration**:
  - Duplicated IAM policy documents across roles
  - Hardcoded VPC endpoint IDs in mappings
  - Missing error handling in Lambda functions
  - No throttling configuration validation

## 5. Technical Debt
- **Hardcoding**:
  - Lambda environment variables contain static values
  - VPC endpoint IDs baked into mappings
  - OrderNumber parameter hardcoded as "000000"
- **Modularity**:
  - No nested stacks or separate configuration files
  - Lambda roles duplicated instead of using shared policies
  - Environment-specific values mixed with globals

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- SAM transform would require conversion to native resources
- Environment variables would need parameter reorganization
- IAM policy documents would require HCL conversion
- SSM parameters would need explicit dependency management

## 7. Recommended Migration Path
1. Convert globals to Terraform variables
2. Migrate Lambda layers as standalone modules
3. Create IAM policy documents as data sources
4. Implement API Gateway with aws_apigatewayv2 resources
5. Migrate Lambda functions with explicit VPC config
6. Replace SSM parameters with Terraform resources
7. Validate private endpoint integration

