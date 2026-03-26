# Repository Assessment: meteorology-operations

## 1. Overview
The repository contains CloudFormation infrastructure for meteorology data processing pipelines including:
- Weather station data ingestion (PSPS operations)
- Fire Potential Index (FPI) processing
- NWS polygon processing
- Weather console updates
- Email notifications
- Lightning data archiving
- Threat detection integration (GuardDuty)

Uses Lambda@Edge, EventBridge, SNS, Glue, EFS, RDS, API Gateway, SQS, Athena, and SecretsManager.

## 2. Architecture Summary
- **Core Pattern**: Event-driven serverless architecture with scheduled batch processing
- **Primary Services**: Lambda, EventBridge, S3, RDS/AuroraDB, Glue, SQS, SNS, EFS, API Gateway, GuardDuty
- **Environments**: dev/qa/test/prod with inconsistent parameter handling
- **Data Flow**:
  - S3/EventBridge → Lambda → RDS/AuroraDB/S3
  - Scheduled events → Lambda → Data aggregation → S3/API
  - Failure monitoring → SNS notifications
  - Threat detection → GuardDuty → EventBridge

## 3. Identified Resources
- 50+ AWS::Serverless::Function (Lambda)
- 20+ AWS::Events::Rule (EventBridge)
- 15+ AWS::Lambda::Permission
- 10+ AWS::SNS::Topic
- 10+ AWS::SNS::Subscription
- 7+ AWS::SQS::Queue
- 7+ AWS::Glue::Job
- 3+ AWS::Glue::Crawler
- 2+ AWS::IAM::Role (Glue)
- 1+ AWS::GuardDuty::Detector
- Multiple S3 buckets, IAM roles, and Lambda layers

## 4. Issues & Risks
- **Security**:
  - Overly permissive IAM policies (s3:*, kms:*, ec2:*, rds:*)
  - Hardcoded KMS/ARN values
  - Public S3 bucket references
  - Missing encryption configurations
  - Privilege escalation risks (iam:* permissions)
  - Lambda functions with AWSLambda_FullAccess

- **Configuration**:
  - Inconsistent environment handling
  - Disabled resources still defined
  - Hardcoded region references
  - Missing dead-letter queues
  - Security group typos

## 5. Technical Debt
- **Modularization**:
  - Repeated policy documents
  - No nested stacks
  - Lambda configuration duplication
- **Hardcoding**:
  - Explicit ARNs instead of aliases
  - Mixed environment variables
- **Maintainability**:
  - Deprecated runtimes (Python 3.7/3.8)
  - Inconsistent naming conventions
  - Missing version control
- **Compliance**:
  - Missing retention policies
  - Inconsistent encryption

## 6. Terraform Migration Complexity
Moderate to High due to:
- Complex IAM policies
- SSM parameter dependencies
- SAM transform usage
- Lambda layer versioning
- Mixed runtime environments

## 7. Recommended Migration Path
1. Convert core Lambda/S3/IAM resources first

