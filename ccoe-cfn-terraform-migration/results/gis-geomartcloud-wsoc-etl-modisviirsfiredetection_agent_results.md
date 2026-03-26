# Repository Assessment: gis-geomartcloud-wsoc-etl-modisviirsfiredetection

## 1. Overview
This CloudFormation template provisions ETL infrastructure for geospatial fire detection using AWS Glue and related services. It creates IAM roles, Glue jobs, triggers, and security groups while leveraging SSM parameters for configuration management.

## 2. Architecture Summary
The solution uses:
- AWS Glue for ETL orchestration
- S3 for artifact storage
- IAM roles with broad permissions
- CloudWatch for logging
- Security groups for network isolation
- SSM Parameter Store for configuration

## 3. Identified Resources
- 1x IAM Role (gluerole)
- 1x Glue Job (MyGlueJob)
- 1x Glue Trigger (ScheduledJobTrigger)
- 1x EC2 Security Group (SecurityGroup)
- 1x Security Group Ingress Rule (SecurityGroupIngress)

## 4. Issues & Risks
- **Security**: IAM role has 10 policies with `Resource: "*"` including `s3:*`, `ec2:*`, `logs:*`, and `secretsmanager:*`
- **Compliance**: Hardcoded "Compliance: None" in tags
- **Configuration**: Uses deprecated `AWS::SSM::Parameter::Value` syntax
- **Environment Handling**: Only prod environment starts jobs automatically
- **Missing Resources**: Commented-out Glue Connection and SecretsManager resources

## 5. Technical Debt
- **Hardcoded Values**: Tags like "Notify: rqrb@pge.com" and "DRTier: TIER 2"
- **Policy Sprawl**: 10 separate policy statements with overlapping permissions
- **Resource Coupling**: Glue job references S3 paths directly
- **Modularization**: Single template handles all components

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean mappings exist for IAM, Glue, and EC2 resources
- SSM parameter references would require `aws_ssm_parameter` data sources
- Security group self-reference pattern needs adjustment
- Would require decomposition into Terraform modules

## 7. Recommended Migration Path
1. Create Terraform data sources for all SSM parameters
2. Migrate security group and ingress rules first
3. Convert IAM role using aws_iam_policy_document
4. Implement Glue job with dynamic S3 references
5. Add missing resources (if needed) with proper Terraform patterns
6. Validate with `terraform plan` before deployment

