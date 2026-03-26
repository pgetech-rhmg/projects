# Repository Assessment: gis_geomartcloud_customercare_datasync

## 1. Overview
Partial CloudFormation template for customer care data synchronization infrastructure. Configures Lambda function with VPC networking and environment-specific parameters.

## 2. Architecture Summary
Deploys a single Lambda function in a VPC with three private subnets. Uses SSM parameters for environment configuration and hardcoded IAM role. Includes database layer dependency (psycopg2) suggesting database integration.

## 3. Identified Resources
- AWS::Lambda::Function (customercare-uploadcustomerparcel-${ENV})

## 4. Issues & Risks
- **Hardcoded IAM Role ARN**: Uses static LambdaRole ARN (412551746953) that won't work across accounts
- **Deprecated Runtime**: Python 3.7 reaches EOL 2023-06-27
- **Missing Resource Policies**: Lambda execution role permissions not defined in template
- **Security Group Exposure**: References existing SG without validation
- **No Dead Letter Queue**: Lambda lacks error handling configuration

## 5. Technical Debt
- **Parameter Sprawl**: 6 SSM parameters for basic configuration
- **Hardcoded Layer ARN**: Database layer version (psycopg2:3) is static
- **No Environment Separation**: Single template for all environments
- **Inline Code**: Uses ZipFile property instead of S3 deployment package

## 6. Terraform Migration Complexity
Moderate. Requires:
- Refactoring SSM parameters to Terraform data sources
- Decomposing hardcoded ARNs into variables
- Adding missing IAM role resources
- Handling inline code migration

## 7. Recommended Migration Path
1. Create Terraform data sources for all SSM parameters
2. Define Lambda execution role as Terraform resource
3. Migrate Lambda configuration with dynamic references
4. Add S3 backend for Lambda deployment packages
5. Validate VPC/subnet/SG references via data sources

