# Repository Assessment: emergency-website-backup-publish

## 1. Overview
The CloudFormation template establishes a CI/CD pipeline for synchronizing emergency website error pages between GitHub, S3, CloudFront, and Akamai. Uses Lambda for automation and Secrets Manager for credential storage.

## 2. Architecture Summary
- **Source Control**: GitHub repository with emergency content
- **CI/CD**: CodePipeline with CodeBuild for build automation
- **Storage**: Two S3 buckets (artifacts + website content) with AES-256 encryption
- **Automation**: Lambda function handles S3 events to update CloudFront distributions
- **CDN**: CloudFront distribution with custom error pages
- **Edge Network**: Akamai integration via EdgeGrid API
- **Security**: Secrets Manager for API tokens

## 3. Identified Resources
- SecretsManager::Secret (4x)
- IAM::Role (3x)
- S3::Bucket (2x)
- S3::BucketPolicy (2x)
- Lambda::Function (1x)
- Lambda::Permission (2x)
- CodePipeline::Pipeline (1x)
- CodeBuild::Project (1x)

## 4. Issues & Risks
- **Security**:
  - Lambda execution role has overly permissive policies (ssm:*, s3:*, cloudfront:*)
  - S3 bucket policies allow full access to entire AWS account
  - Hardcoded AWS region in CodeBuild environment variables
  - Missing VPC endpoints for S3/SecretsManager
- **Reliability**:
  - Lambda uses deprecated Python 3.7 runtime
  - No error handling for critical CloudFront update operations
- **Configuration**:
  - S3 bucket names hardcoded with region suffix
  - Lambda environment variables contain redundant values
  - CodeBuild project uses fixed region instead of parameter

## 5. Technical Debt
- **Modularization**:
  - Single template combines infrastructure, application, and security layers
  - No nested stacks or separate modules
- **Hardcoding**:
  - Lambda code contains static error codes and paths
  - S3 bucket names and policies use literal values
- **Parameter Management**:
  - 27 parameters with inconsistent naming conventions
  - Redundant parameters (pS3WebBucketID vs pAkamaiEGridURL)

## 6. Terraform Migration Complexity
Moderate complexity:
- Standard AWS services map cleanly to Terraform providers
- Requires decomposition into modules (IAM, S3, Lambda, CI/CD)
- Secrets Manager integration needs secure parameter handling
- Lambda inline code would become file-based resources

## 7. Recommended Migration Path
1. Create Terraform state backend configuration
2. Migrate parameter store references to SSM provider
3. Build core infrastructure modules:
   - IAM roles with least-privilege policies
   - S3 buckets with proper encryption and policies
   - Secrets Manager resources
4. Implement application modules:
   - Lambda function with externalized code
   - CodePipeline/CodeBuild with environment variables
5. Validate with terraform plan and incremental apply

