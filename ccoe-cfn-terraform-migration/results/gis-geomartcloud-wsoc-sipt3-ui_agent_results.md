# Repository Assessment: gis-geomartcloud-wsoc-sipt3-ui

## 1. Overview
The repository contains CloudFormation templates for deploying a secure static website infrastructure with CI/CD pipeline prerequisites. Key components include secrets management, S3 bucket hosting, DNS-validated ACM certificates, WAF protection, and CloudFront distribution.

## 2. Architecture Summary
- **Secrets Management**: Uses Secrets Manager for GitHub tokens
- **Storage**: S3 bucket with AES256 encryption and referer-based access control
- **Security**: 
  - WAFv1 (deprecated) with IP whitelisting
  - DNS-validated ACM certificates via custom Lambda resource
  - HTTPS-only CloudFront distribution
- **Networking**: Route 53 CNAME records for domain mapping
- **CI/CD**: Prerequisites for pipeline execution roles

## 3. Identified Resources
- AWS::SecretsManager::Secret
- AWS::S3::Bucket + BucketPolicy
- AWS::Lambda::Function + IAM::Role
- Custom::DNSCertificate (Lambda-backed ACM)
- AWS::WAF(v1)::IPSet/Rule/WebACL
- AWS::CloudFront::Distribution
- Custom::CNAME (Route 53 integration)

## 4. Issues & Risks
- **Security**:
  - S3 bucket policy uses deprecated `aws:CloudHouse` principal
  - WAFv1 resources should migrate to WAFv2
  - Lambda function contains hardcoded logic (obfuscated code)
  - Missing S3 bucket logging configuration
  - No VPC endpoints for S3/CloudFront access
- **Configuration**:
  - Duplicate pWebsiteFQDN parameters in ui.yml
  - Inconsistent parameter naming (pEnv vs pTaskEnv)
  - Hardcoded TLSv1 in CloudFront origin config
- **Reliability**:
  - No versioning/backup for Lambda function
  - No failure handling in custom resource Lambda

## 5. Technical Debt
- **Modularization**:
  - Single Lambda handles all certificate operations
  - No nested stacks or separate modules
- **Hardcoding**:
  - Lambda uses Python 3.6 (deprecated runtime)
  - WAF IP ranges duplicated between regional/global stacks
- **Maintainability**:
  - Inconsistent tagging strategy
  - Missing environment-specific parameters
  - No lifecycle policies for resources

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for S3/IAM/CloudFront
- Custom Lambda resources require:
  - Code extraction to .zip files
  - Refactoring to Terraform AWS provider
- WAFv1 resources need conversion to WAFv2 equivalents
- Complex policy documents would benefit from HCL formatting

## 7. Recommended Migration Path
1. **Prerequisites**: Establish Terraform state backend (S3+DynamoDB)
2. **Phase 1**: Migrate static resources:
   - S3 bucket (with policy fixes)
   - Route 53 parameters
   - IAM roles (with policy cleanup)
3. **Phase 2**: Refactor Lambda:
   - Extract to standalone .zip
   - Create terraform aws_lambda

