# Repository Assessment: meteorology-psps-reporting

## 1. Overview
The repository contains CloudFormation templates for a meteorology data processing pipeline using AWS Glue, Lambda, RDS Aurora Postgres, SNS, KMS, and Step Functions. It implements ETL workflows for operational model integration from S3 data sources, database connectivity, and scheduled monitoring.

## 2. Architecture Summary
- **Data Ingestion**: S3 buckets host raw data and trigger Lambda functions
- **Processing**: AWS Glue jobs (Python/Spark) perform ETL operations
- **Orchestration**: Step Functions manage job dependencies and error handling
- **Storage**: RDS Aurora Postgres cluster stores processed data
- **Monitoring**: CloudWatch logs, SNS notifications, and EventBridge rules track job status
- **Security**: IAM roles with SSM parameters, KMS encryption, and VPC isolation

## 3. Identified Resources
- **Core Services**:  
  S3 (buckets/events), Lambda (10+ functions), Glue (jobs/crawlers/databases), RDS (Aurora Postgres), Step Functions, KMS, DynamoDB, EC2 (bootstrap), IAM (roles/policies), SNS (topics/subscriptions), CloudWatch (logs/events)

- **Key Patterns**:  
  Lambda-triggered Glue workflows, cross-account S3 access, environment-specific parameters, SSM parameter store integration, and KMS-encrypted data pipelines

## 4. Issues & Risks
- **Security**:  
  - Overly permissive IAM policies (s3:*, kms:*, sns:*)  
  - Hard-coded KMS key policies with wildcard principals  
  - Missing S3 bucket policies (public access risk)  
  - Lambda functions using root credentials in ec2-bootstrap template  
  - Glue jobs have database deletion permissions  
  - Duplicate resource declarations (LambdaInvokePermission in MET-S3EventNotification-Deploy.yaml)

- **Reliability**:  
  - No dead-letter queues for Lambda failures  
  - Static Glue crawler configurations  
  - Missing error handling in Lambda custom resources  
  - Lambda timeouts set to 900s (may need adjustment)

- **Operational**:  
  - Python 3.7 runtime (end-of-support June 2023)  
  - Hard-coded region references (us-west-2)  
  - Inconsistent environment parameter casing (DEV vs dev)  
  - Missing versioning on Glue scripts

## 5. Technical Debt
- **Modularization**:  
  - Repeated IAM role definitions across templates  
  - Mixed resource types in single templates  
  - No nested stacks or modules  
  - Hard-coded resource names ("pge-meteoqa-oamodel")

- **Configuration Management**:  
  - SSM parameter path inconsistencies  
  - Missing parameter constraints  
  -

## 6. Terraform Migration Complexity
Not Observed

## 7. Recommended Migration Path
Not Observed

