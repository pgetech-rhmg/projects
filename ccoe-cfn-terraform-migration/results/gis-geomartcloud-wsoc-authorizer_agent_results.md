# Repository Assessment: gis-geomartcloud-wsoc-authorizer

## 1. Overview
This CloudFormation template creates a Lambda-based API authorizer with group filtering capabilities. It establishes secure authentication patterns using Ping Federate for internal/external users and enforces least-privilege IAM policies. The implementation follows enterprise security policies requiring VPC isolation, KMS encryption, and X-Ray tracing.

## 2. Architecture Summary
The solution implements:
- Lambda function with VPC integration for network isolation
- KMS key for environment variable encryption
- Custom IAM role with X-Ray permissions
- Security group with self-referential ingress rules
- Parameterization through AWS SSM Parameter Store
- Audience-based authentication logic (AD vs LDAP)

## 3. Identified Resources
- IAM::ManagedPolicy (rTracerPolicy)
- IAM::Role (rAuthorizerExecutionRole)
- KMS::Key (rCmkKeyForLambdaEnvVars)
- KMS::Alias (rCmkKeyForLambdaEnvVarsAlias)
- EC2::SecurityGroup (rLambdaSecurityGroup)
- EC2::SecurityGroupIngress (rLambdaSecurityGroupIngress)
- Lambda::Function (rLambdaAuthorizer)

## 4. Issues & Risks
- **Security Group Configuration**: Uses self-referential ingress (IpProtocol: -1, SourceSecurityGroupId: self) which creates circular dependency but no actual ingress rules
- **KMS Key Permissions**: Grants kms:* to root/admin roles - violates least privilege
- **Hardcoded Region**: Lambda layer ARN hardcodes us-west-2
- **Missing Outputs**: No stack exports for critical values like Lambda ARN
- **Wildcard Resources**: IAM policies and KMS key use "*" resources
- **Environment Variable Exposure**: CLIENT_SECRET stored as plaintext parameter

## 5. Technical Debt
- **Parameter Sprawl**: 16 parameters with overlapping tagging values
- **Hardcoded Values**: Lambda timeout (3s), VPC subnet references
- **Tight Coupling**: Security group depends directly on Lambda resource
- **Missing Lifecycle Controls**: No retention policies or deletion protections

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- SSM parameter lookups would use aws_ssm_parameter data sources
- Security group self-reference requires explicit depends_on
- IAM policy documents would need HCL conversion
- Lambda VPC configuration syntax differs slightly

## 7. Recommended Migration Path
1. Convert core resources (KMS, IAM, Lambda) to Terraform modules
2. Migrate SSM parameter references to data sources
3. Implement Terraform state management (S3+DynamoDB)
4. Validate with terraform plan against existing stack
5. Incremental rollout using resource importing

