# Repository Assessment: gis-geomartcloud-wsoc-detour-ui

## 1. Overview
The repository contains CloudFormation templates for deploying a secure static website infrastructure with CI/CD pipeline prerequisites. It establishes secrets management, S3 hosting, DNS-validated ACM certificates, WAF protections, and CloudFront distribution with HTTPS termination.

## 2. Architecture Summary
- **Core Pattern**: Static website hosted on S3 with CloudFront CDN
- **Security**: WAF IP whitelisting, HTTPS-only access, referer-based S3 access control
- **Automation**: Custom Lambda for DNS certificate validation, cross-account Route53 management
- **Environment**: PROD tagging but lacks environment-specific configurations

## 3. Identified Resources
- AWS::SecretsManager::Secret
- AWS::S3::Bucket + BucketPolicy
- AWS::Lambda::Function + IAM::Role
- Custom::DNSCertificate (Lambda-backed)
- AWS::WAF(Regional|Global)::IPSet + Rule + WebACL
- AWS::CloudFront::Distribution
- Custom::CNAME (Route53 cross-account)

## 4. Issues & Risks
- **Security**:
  - Hardcoded IP ranges in WAF rules (maintenance risk)
  - Public S3 bucket policy with referer condition (risk of misconfiguration)
  - Lambda execution role has overly broad acm:* and route53:* permissions
  - TLSv1/TLSv1.1 enabled in CloudFront origin configuration
- **Configuration**:
  - S3 bucket policy uses "Amazon CloudHouse" (likely typo for CloudFront)
  - Missing VPC/network controls for Lambda
  - No logging configuration for Lambda function
  - Hardcoded us-east-1 region in certificate resource

## 5. Technical Debt
- **Modularity**:
  - Duplicated parameters across templates (pAppID, pEnv, etc.)
  - Inline Lambda code (200+ lines) reduces maintainability
  - No separation between environment-specific values and core infrastructure
- **Hardcoding**:
  - Fixed IP ranges in WAF rules
  - Hardcoded S3 error document (index.html)
  - Fixed TLS protocols in CloudFront origin
- **Missing Features**:
  - No versioning/lifecycle policies for S3
  - No cache invalidation mechanism
  - No automated certificate renewal handling

## 6. Terraform Migration Complexity
Moderate to High. Key challenges:
- Custom Lambda resources would require extraction to separate modules
- Inline Lambda code needs externalization
- WAFv1 resources (AWS::WAF::*) require migration to WAFv2
- Complex parameter dependencies between templates
- Cross-account Route53 management would need provider configuration

## 7. Recommended Migration Path
Not Observed
