# Repository Assessment: ew-post-apis

## 1. Overview
The repository contains a CloudFormation template for a serverless API infrastructure using AWS SAM. It deploys an API Gateway with multiple POST endpoints backed by Lambda functions, custom authorizers, VPC integration, environment-specific configurations, and monitoring alarms.

## 2. Architecture Summary
- **Core Services**: API Gateway (HTTP API), Lambda, IAM, CloudWatch Alarms, SSM Parameter Store
- **Patterns**:
  - Serverless microservices architecture
  - Custom Lambda authorizer for Entra ID integration
  - Environment-aware configuration via SSM parameters and Mappings
  - VPC-connected Lambda functions with shared security groups
  - Layer-based dependency management for Node.js runtime

## 3. Identified Resources
- 1x API Gateway (Regional endpoint with custom domain)
- 10x Lambda Functions (Node.js 22.x runtime)
- 10x IAM Roles with inline policies
- 15x CloudWatch Alarms (error rates, throttles, duration)
- 7x Lambda Layers for code reuse
- 1x API Gateway Usage Plan

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (Resource: "*") in all roles
  - Hardcoded secrets in environment variables (ADMS credentials)
  - Missing WAF integration on API Gateway
  - Public S3 bucket references in IAM policies
  - No explicit encryption configuration for S3 buckets
- **Reliability**:
  - Missing dead-letter queues for async processing
  - No retries/exponential backoff in Lambda error handling
- **Operational**:
  - High parameter count (40+) using SSM workaround
  - Inconsistent alarm thresholds between functions
  - Missing versioning on Lambda layers

## 5. Technical Debt
- **Modularization**:
  - Single monolithic template - difficult to manage at scale
  - No nested stacks or cross-stack references
- **Configuration**:
  - Hardcoded ARNs and resource names
  - Environment-specific values mixed with generic parameters
  - Missing tagging strategy for cost allocation
- **Maintainability**:
  - Repeated policy statements across IAM roles
  - Inconsistent timeout values between Lambda functions
  - No lifecycle policies for old versions

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (API Gateway, Lambda, IAM)
- Would require:
  - Decomposing into Terraform modules (auth, endpoints, layers)
  - Refactoring IAM policies to use data sources
  - Handling SAM-specific syntax (AuthApi events)
  - Managing environment separation through workspaces

## 7. Recommended Migration Path
1. **Preparation**:
   - Establish Terraform state backend (S3+DynamoDB)
   - Create parameter mapping files for environment variables
   - Define tagging conventions

2. **Core Infrastructure**:
   - Migrate VPC configuration (if not shared)
   - Create base IAM roles with least-privilege policies
   - Implement API Gateway module with domain configuration

3. **Lambda Functions**:
   - Convert each function to Terraform module
   - Replace SSM parameter references with variables
   - Add secrets

