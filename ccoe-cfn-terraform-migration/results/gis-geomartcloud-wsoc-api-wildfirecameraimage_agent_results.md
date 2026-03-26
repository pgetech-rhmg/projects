# Repository Assessment: gis-geomartcloud-wsoc-api-wildfirecameraimage

## 1. Overview
This CloudFormation template provisions a serverless API infrastructure for wildfire camera image processing in a GeoMart cloud environment. It deploys API Gateway endpoints backed by AWS Lambda functions with VPC integration, IAM roles, and CORS configuration. The solution emphasizes security through private API endpoints and environment-specific configurations.

## 2. Architecture Summary
- **API Gateway**: Private REST API with CORS support and custom Lambda authorizer
- **Lambda Functions**: Python 3.9 runtime with VPC integration and environment-specific layers
- **Security**: IAM roles with least-privilege policies and KMS encryption
- **Networking**: VPC-enabled Lambda with security group isolation
- **Observability**: X-Ray tracing and CloudWatch logging

## 3. Identified Resources
- AWS::ApiGateway::RestApi
- AWS::ApiGateway::Resource (2x)
- AWS::ApiGateway::Method (4x)
- AWS::ApiGateway::Authorizer
- AWS::ApiGateway::Stage
- AWS::ApiGateway::Deployment
- AWS::Lambda::Function
- AWS::IAM::Role (2x)
- AWS::EC2::SecurityGroup
- AWS::EC2::SecurityGroupIngress

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: 
  - Lambda role has s3:* and secretsmanager:* permissions
  - API Gateway role uses lambda:* instead of scoped permissions
- **Hardcoded Secrets**: DT_CONNECTION_AUTH_TOKEN appears hardcoded in environment variables
- **Missing Dead Letter Queue**: SQS configuration parameters exist but no SQS resource declared
- **Insecure CORS**: Access-Control-Allow-Origin: "*" in multiple places
- **Unused Parameters**: pdefaultsecuritygroup and pvpclambdaapiendpoint commented out
- **Lambda Environment Variables**: DT_TAGS contains hardcoded QA environment reference

## 5. Technical Debt
- **Parameter Sprawl**: 18 parameters with inconsistent naming conventions
- **Tight Coupling**: Lambda function directly references VPC subnet IDs
- **No Output Exports**: Critical values like API Gateway ID not exported for cross-stack references
- **No Lifecycle Policies**: Missing retention policies for logs/data
- **Region Hardcoding**: us-west-2 hardcoded in multiple ARN references

## 6. Terraform Migration Complexity
Moderate complexity:
- Standard resources map cleanly to Terraform providers
- Requires decomposition of:
  - IAM policy documents
  - API Gateway resource hierarchy
  - Lambda environment variable structures
- Challenges in:
  - Maintaining VPC endpoint security model
  - Translating Fn::Sub syntax
  - Handling SSM parameter references

## 7. Recommended Migration Path
1. **IAM Stage**: Convert roles and policies first
2. **Networking**: Migrate VPC security group configuration
3. **Lambda**: Create function with environment variables
4. **API Gateway**: Build endpoint structure with methods
5. **Incremental Deployment**:
   - Use Terraform data sources for existing SSM parameters
   - Validate with `terraform plan` before applying

