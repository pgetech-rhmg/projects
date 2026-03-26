# Repository Assessment: gis-geomartcloud-wsoc-dashboards3-ui

## 1. Overview
The repository contains CloudFormation templates for deploying a secure static website hosted on S3 with CloudFront distribution, WAF protection, and DNS validation via Route53. Includes secrets management for GitHub tokens and automated certificate provisioning.

## 2. Architecture Summary
- **Core Services**: S3 (static hosting), CloudFront (CDN), WAF (security), ACM (SSL), Route53 (DNS), Secrets Manager (credentials), Lambda (custom certificate automation)
- **Pattern**: Static website pattern with edge security and automated certificate management
- **Environment**: Appears production-oriented with PROD tagging but contains deprecated WAFv1 resources

## 3. Identified Resources
- SecretsManager::Secret
- S3::Bucket + BucketPolicy
- Lambda::Function + IAM::Role
- Custom::DNSCertificate (Lambda-backed)
- WAFRegional/WAF::IPSet + Rule + WebACL
- CloudFront::Distribution
- Custom::CNAME (Route53 record)

## 4. Issues & Risks
- **Security**:
  - S3 bucket policy uses deprecated "Amazon CloudHouse" principal
  - WAFv1 resources (AWS::WAF::*) should migrate to WAFv2
  - CloudFront Origins allow TLSv1/1.1 (security risk)
  - Missing S3 bucket policy requiring HTTPS
  - No VPC endpoints for S3 access
- **Configuration**:
  - Hardcoded TLSv1 in CloudFront Origins
  - Lambda function uses deprecated Python 3.6 runtime
  - Inconsistent parameter naming (pEnv vs pTaskEnv)
  - Missing validation on pWebsiteFQDN parameter

## 5. Technical Debt
- **Modularity**: Single monolithic template structure
- **Hardcoding**: Explicit TLS versions and WAF rule IPs
- **Maintainability**: Obfuscated Lambda code with no version control
- **Environment Handling**: Uses PROD tags but lacks environment-specific parameters
- **Lifecycle**: No deletion policies or retention rules

## 6. Terraform Migration Complexity
Moderate complexity:
- Clean 1:1 mappings exist for most resources
- Custom Lambda resources require refactoring
- WAFv1 → WAFv2 migration needed
- Complex IAM policies would benefit from HCL syntax
- Would require parameter reorganization

## 7. Recommended Migration Path
1. Decompose into Terraform modules:
   - secrets/
   - s3_bucket/
   - dns_certificate/
   - waf/
   - cloudfront/
2. Migrate stateful resources first (S3 bucket)
3. Implement WAFv2 equivalents
4. Convert Lambda to Terraform with proper deployment packaging
5. Validate all parameters with proper types
6. Establish state management strategy

