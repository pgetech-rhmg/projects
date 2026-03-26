# Repository Assessment: nodejs-lambda-sample

## 1. Overview
This repository contains a SAM-based CloudFormation template for a Node.js Lambda function with X-Ray integration and dependency layers. Includes partial CodeDeploy configuration for blue/green deployments.

## 2. Architecture Summary
- **Core Service**: AWS Lambda (Node.js 16.x runtime)
- **Deployment**: SAM framework with implicit API Gateway trigger
- **Observability**: AWS X-Ray tracing enabled
- **Dependencies**: Custom Lambda layer for shared libraries
- **Deployment Strategy**: Partial CodeDeploy configuration (blue/green hooks commented out)

## 3. Identified Resources
- AWS::Serverless::Function (Lambda)
- AWS::Serverless::LayerVersion (Lambda layer)
- AWS::Lambda::Function (CodeDeploy resource reference)

## 4. Issues & Risks
- **Security**: Overly permissive IAM policies (AWSLambda_ReadOnlyAccess grants read access to all Lambda resources)
- **Configuration**: Hardcoded timeout (10s) and runtime version
- **Observability**: Missing CloudWatch log retention policy
- **Deployment**: CodeDeploy hooks disabled - no validation during traffic shifts

## 5. Technical Debt
- **Hardcoding**: Runtime version and timeout not parameterized
- **Modularity**: Single template combines infrastructure and application code references
- **Environment Separation**: No environment-specific parameters detected

## 6. Terraform Migration Complexity
Moderate. SAM constructs require translation to native Terraform resources:
- Lambda function + layers → aws_lambda_function + aws_lambda_layer_version
- Implicit API Gateway → explicit aws_apigatewayv2 resources
- X-Ray permissions require manual IAM policy decomposition

## 7. Recommended Migration Path
1. Decompose SAM template into Terraform modules:
   - Lambda function module
   - Layer module
   - API Gateway module (if needed)
2. Parameterize environment variables
3. Migrate IAM policies to aws_iam_policy_document
4. Implement missing log retention
5. Validate CodeDeploy integration with Terraform deployment workflows

