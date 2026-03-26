# Repository Assessment: gis-geomartcloud-pspsV4-etl-datasync

## 1. Overview
The repository contains a CloudFormation template (ci/cf-glue-pipeline.yml) that provisions ETL infrastructure for geospatial data synchronization. It deploys Lambda functions to trigger AWS Glue jobs, with supporting IAM roles and security groups. The solution emphasizes data classification and compliance tagging.

## 2. Architecture Summary
- **Core Services**: Lambda, Glue, IAM, S3, CloudWatch Logs
- **Pattern**: Event-driven ETL pipeline using Lambda triggers and Glue jobs
- **Security**: Uses SSM Parameter Store for sensitive values and applies environment-specific tagging
- **Data Flow**: Lambda → Glue Job A/B → S3 artifacts with external dependencies

## 3. Identified Resources
- IAM Roles: Lambda execution role, Glue service role
- Security Groups: Lambda-specific SG with self-referential ingress
- Lambda Function: Python 3.7 handler with VPC configuration
- Glue Jobs: Two jobs (A/B) with identical configurations except connection names
- S3 Bucket References: For Glue scripts and dependencies

## 4. Issues & Risks
- **Overly Permissive IAM**: Both roles use 20+ wildcard actions ("s3:*", "logs:*")
- **Duplicate Declaration**: rLambdaSecurityGroup defined twice (lines 104-127 and 163-186)
- **Hardcoded Values**: Glue jobs reference fixed S3 paths and Python versions
- **Missing VPC Endpoints**: Glue jobs may require explicit VPC endpoints for S3 access
- **No Encryption Enforcement**: S3 buckets referenced don't show KMS configuration
- **Lambda Timeout**: 900s (15m) may exceed best practices for synchronous operations

## 5. Technical Debt
- **Parameter Sprawl**: 19 parameters with overlapping purposes (pEnv vs pTaskEnv)
- **Tight Coupling**: Glue jobs hardcode external dependencies (S3 paths, JAR versions)
- **No Lifecycle Management**: Missing retention policies for logs/artifacts
- **Inconsistent Naming**: pArtifactsBukcet typo in parameter name

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for core resources (IAM, Lambda, Glue)
- Would require:
  - Refactoring duplicate SG declarations
  - Modularizing IAM policies
  - Converting Fn::Sub/GetAtt syntax
  - Handling SSM parameter lookups

## 7. Recommended Migration Path
1. Deduplicate security group resources
2. Create Terraform modules for:
   - IAM roles with policy attachments
   - Lambda+VPC configuration
   - Glue job definitions
3. Migrate parameters to Terraform variables with validation
4. Use Terraform data sources for SSM parameters
5. Implement gradual rollout:
   - First IAM roles
   - Then Lambda function
   - Finally Glue jobs

