# Repository Assessment: aws_obm_integration

## 1. Overview
This repository implements a Cloud Operations Bridge Monitoring (OBM) integration using AWS CloudFormation. It creates Lambda functions, API Gateway endpoints, SNS topics, and EventBridge rules to forward AWS alerts to an external OBM system. The solution includes CI/CD pipelines for automated deployment.

## 2. Architecture Summary
- **Core Components**: Lambda functions handle alert processing, SNS topics for message routing, EventBridge for event ingestion, and API Gateway for external alert submission
- **Security**: Uses IAM roles with least privilege (though some policies are overly permissive), KMS encryption for sensitive Lambda functions, and VPC-attached Lambdas
- **Deployment**: CodePipeline/CodeBuild CI/CD pipeline with environment-specific configurations
- **Patterns**: Event-driven architecture with decoupled components, environment-based configuration via SSM parameters

## 3. Identified Resources
- Lambda Functions (×8)
- IAM Roles (×8)
- SNS Topic (×1)
- EventBridge EventBus (×1)
- EventBridge Rule (×1)
- API Gateway REST API (×1)
- API Gateway Resources/Methods (×1)
- CloudWatch Log Groups (×2)
- CodePipeline Pipeline (×1)
- CodeBuild Project (×1)
- IAM Roles (×4 for pipeline/build)
- Security Group (×1)

## 4. Issues & Risks
- **Security Group Egress**: rOBMIntegrationSecurityGroup allows egress to 0.0.0.0/0 on port 443 - violates least privilege
- **IAM Permissions**: Multiple roles (e.g. rRoleSendAlarmToSNS) use "*" resources for SNS/EC2/KMS permissions
- **Encryption**: API Gateway stage logging and some Lambda functions lack explicit encryption
- **Hardcoded Values**: API Gateway policy references hardcoded VPC endpoint ID
- **SNS Policy**: Allows all AWS accounts to publish to SNS topic via condition

## 5. Technical Debt
- **Parameter Sprawl**: 15+ SSM parameters across templates
- **Modularization**: Single monolithic template - should split into modules (networking, compute, pipeline)
- **Environment Handling**: Uses QA/Prod parameters but lacks environment-specific resource naming
- **Logging**: Inconsistent retention periods (1 day vs default)

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources (Lambda, IAM, SNS, EventBridge)
- API Gateway configuration would require refactoring
- SSM parameter lookups would use data sources
- Custom Lambda resources need conversion
- CI/CD pipeline would map to AWS CodePipeline provider

## 7. Recommended Migration Path
1. Establish Terraform state backend (S3+DynamoDB)
2. Create core network module (VPC/subnets/security groups)
3. Migrate IAM roles as modules with policy attachments
4. Convert Lambda functions and EventBridge resources
5. Refactor API Gateway using Terraform aws_apigatewayv2 resources
6. Implement CI/CD pipeline last
7. Validate with terraform plan/apply in non-prod environment
