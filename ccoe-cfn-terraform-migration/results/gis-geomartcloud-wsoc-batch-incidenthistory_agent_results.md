# Repository Assessment: gis-geomartcloud-wsoc-batch-incidenthistory

## 1. Overview
The CloudFormation template provisions infrastructure for a batch incident history processing system in AWS. Focuses on Lambda function deployment with SQS integration, IAM permissions, VPC networking, and environment-specific configurations. Many ECS/Fargate components are commented out.

## 2. Architecture Summary
- **Core Service**: AWS Lambda function for incident report generation
- **Trigger**: SQS queue event source mapping
- **Networking**: VPC-connected Lambda with private subnet placement
- **Security**: IAM role with broad permissions and security group self-reference
- **Observability**: CloudWatch Logs integration and X-Ray tracing
- **Environment**: Parameterized for dev/test/prod environments

## 3. Identified Resources
- **IAM Role**: Lambda execution role with 23 AWS service permissions
- **Security Group**: For Lambda with self-referential ingress rule
- **Lambda Function**: Python 3.9 runtime with 5 layers and environment variables
- **Event Source Mapping**: SQS queue trigger for Lambda
- **(Commented)**: ECS Task Definition, IAM Roles, SecretsManager Secret

## 4. Issues & Risks
- **Overly Permissive IAM Policies**: Lambda role has s3:*, ec2:*, rds:*, kms:*, etc.
- **Hardcoded Secrets**: DT_CONNECTION_AUTH_TOKEN exposed in plaintext
- **Missing Resource Dependencies**: EventSourceMapping references undefined Lambda ARN
- **Security Group Misconfiguration**: Ingress allows all traffic from itself (redundant)
- **Region Hardcoding**: SQS ARN uses hardcoded "us-west-2"
- **Deprecated Parameter Type**: Uses legacy AWS::SSM::Parameter::Value syntax
- **Inconsistent Environment Handling**: pEnv vs pTaskEnv casing mismatch

## 5. Technical Debt
- **Parameter Sprawl**: 16 parameters with inconsistent naming conventions
- **Tight Coupling**: Lambda depends on 5 external layers with hardcoded ARNs
- **Missing Modularization**: Single monolithic template with ECS components commented out
- **No Lifecycle Management**: No retention policies for logs/resources
- **Inconsistent Tagging**: AppID vs AppId casing mismatch in tags

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for IAM, Lambda, SG resources
- Would require:
  - Refactoring SSM parameters to Terraform data sources
  - Decomposing into modules (networking/compute/security)
  - Handling commented-out resources as optional components
  - Secret management overhaul for Terraform best practices

## 7. Recommended Migration Path
1. Create Terraform data sources for all SSM parameters
2. Build core module for VPC/subnet references
3. Migrate security group as standalone module
4. Implement IAM role with policy attachments
5. Convert Lambda function with environment variable mapping
6. Add SQS event source mapping
7. Validate all ARN references and dependencies
