# Repository Assessment: gis-geomartcloud-wsoc-hawc-wiv-ui

## 1. Overview
The repository contains CloudFormation templates for deploying a secure static website infrastructure with CI/CD pipeline prerequisites. Key components include secrets management, S3 bucket hosting, WAF protection, CloudFront distribution, and DNS validation using Lambda.

## 2. Architecture Summary
- **Secrets Management**: Uses Secrets Manager for GitHub tokens
- **Storage**: S3 bucket with server-side encryption and referer-based access control
- **Security**: WAFv1 (deprecated) with IP whitelisting and TLS enforcement
- **Delivery**: CloudFront distribution with HTTPS-only access
- **DNS**: Custom Lambda resource for Route53 certificate validation
- **Pattern**: Follows S3 static website + CloudFront + WAF pattern

## 3. Identified Resources
- AWS::SecretsManager::Secret
- AWS::S3::Bucket + BucketPolicy
- AWS::Lambda::Function + IAM::Role
- Custom::DNSCertificate (Lambda-backed)
- AWS::WAFRegional::* (WAFv1 - deprecated)
- AWS::WAF::* (WAFv1 - deprecated)
- AWS::CloudFront::Distribution
- Custom::CNAME (Cross-account DNS management)

## 4. Issues & Risks
- **Security**:
  - Uses deprecated WAFv1 resources (AWS::WAF::*) instead of WAFv2
  - Hardcoded TLSv1 in CloudFront OriginSSLProtocols
  - Missing logging for Lambda functions
  - S3 bucket policy allows Amazon CloudFront principal without verification
  - Publicly exposed Lambda function code
- **Configuration**:
  - Duplicate parameters across templates (pNotify, pEnv, etc.)
  - Hardcoded region (us-east-1) in certificate resource
  - Missing versioning on S3 bucket
  - Uses obsolete TLSv1/TLSv1.1 protocols

## 5. Technical Debt
- **Modularization**:
  - Single monolithic template structure
  - No nested stacks or template reuse
- **Hardcoding**:
  - Explicit protocol versions in multiple locations
  - Fixed region references
- **Maintainability**:
  - Obfuscated Lambda code with no source control
  - Duplicated tagging patterns across resources
  - No parameter validation

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Custom Lambda resources would require:
  - Refactoring to Terraform AWS provider
  - Maintaining Python runtime environment
- WAFv1 resources need migration to WAFv2 equivalents
- S3 bucket policies would require HCL conversion
- Parameter management would benefit from Terraform variables

## 7. Recommended Migration Path
1. Establish Terraform state backend (S3+DynamoDB)
2. Migrate core infrastructure first:
   - S3 bucket (with policy conversion)
   - Secrets Manager resources
   - Parameter Store references
3. Refactor Lambda function:
   - Move to Terraform deployment
   - Add proper logging configuration
4. Migrate WAF to v

