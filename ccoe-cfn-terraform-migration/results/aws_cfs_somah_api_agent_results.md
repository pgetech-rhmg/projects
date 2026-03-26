# Repository Assessment: aws_cfs_somah_api

## 1. Overview
The repository contains CloudFormation templates for the SOMAH API system, including Lambda functions, API Gateway configuration, IAM roles, and CI/CD infrastructure. The solution appears to implement a serverless microservices architecture using AWS SAM and Lambda for business logic, with API Gateway as the entrypoint.

## 2. Architecture Summary
- **Core Pattern**: Serverless microservices with Lambda functions behind API Gateway
- **Primary Services**: 
  - AWS Lambda (Python 3.8/3.9 and Node.js 12.x/20.x)
  - API Gateway (REST API with Lambda authorizers)
  - IAM Roles and Policies
  - Amazon S3 (for Lambda layers and deployment artifacts)
  - AWS X-Ray (for tracing)
  - AWS Secrets Manager (for sensitive configuration)
  - CloudWatch Logs
  - CI/CD pipeline using CodePipeline/CodeBuild

## 3. Identified Resources
- Lambda Functions (15+ handlers)
- Lambda Layers (Python/Node.js dependencies)
- API Gateway REST API (Regional + Private endpoints)
- IAM Roles (with both inline and managed policies)
- S3 Buckets (for deployment artifacts)
- CodePipeline/CodeBuild resources
- CloudWatch Events rules (for scheduled tasks)
- Security Groups (referenced via SSM parameters)

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies with resource:"*" in all Lambda execution roles
- **Reliability**: Missing dead-letter queues for Lambda functions
- **Compliance**: Hardcoded email addresses in parameters
- **Networking**: Potential VPC cold-start issues from Lambda VPC configuration
- **Observability**: Inconsistent logging levels between templates
- **Configuration**: Duplicated parameters (pAppName vs pApplicationName)

## 5. Technical Debt
- **Modularization**: High duplication between SAM and non-SAM Lambda definitions
- **Parameter Management**: 18 SSM parameters but inconsistent usage patterns
- **Versioning**: Mixed Lambda runtime versions (Python 3.8/3.9, Node.js 12.x/20.x)
- **State Management**: No DynamoDB tables detected for stateful operations
- **Legacy Patterns**: Use of AWS::Lambda::Function instead of SAM in some templates

## 6. Terraform Migration Complexity
Moderate to High complexity due to:
- SAM transform usage requiring AWS provider 4.x+
- Mixed Lambda resource types needing normalization
- Complex IAM policy conversion
- Parameter Store dependencies requiring refactoring
- CI/CD pipeline requiring AWS CodeBuild module

## 7. Recommended Migration Path
1. Convert Lambda layers to Terraform (aws_lambda_layer_version)
2. Migrate S3 bucket resources
3. Create Terraform IAM modules with proper scoping
4. Implement API Gateway in stages using aws_apigatewayv2 resources
5. Convert

