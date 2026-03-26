# Repository Assessment: gis-geomartcloud-wsoc-wiv-ui

## 1. Overview
The repository contains CloudFormation templates for deploying a secure static website infrastructure with CI/CD pipeline prerequisites. It establishes secrets management, S3 hosting, WAF protections, DNS validation, and CloudFront distribution for a web application.

## 2. Architecture Summary
- **Secrets Management**: Uses AWS Secrets Manager to store GitHub OAuth tokens
- **Storage**: S3 bucket with AES256 encryption and referer-based access control
- **Security**: 
  - WAFv1/WAFv2 IP whitelisting with regional/global support
  - TLS 1.2+ enforcement via CloudFront
  - DNS-validated ACM certificates
- **Delivery**: CloudFront distribution with HTTPS redirection
- **DNS**: Cross-account Route53 CNAME management

## 3. Identified Resources
- AWS::SecretsManager::Secret
- AWS::S3::Bucket + BucketPolicy
- AWS::Lambda::Function + IAM::Role
- Custom::DNSCertificate
- AWS::WAF(v1/v2)::IPSet + Rule + WebACL
- AWS::CloudFront::Distribution
- Custom::CNAME

## 4. Issues & Risks
- **Security**:
  - S3 bucket policy uses deprecated "Amazon CloudHouse" principal
  - WAFv1 resources (AWS::WAF::*) are legacy
  - Hardcoded IP ranges in WAF rules
  - Lambda execution role has overly permissive Route53 access
- **Reliability**:
  - S3 bucket name collision risk (direct FQDN reference)
  - CloudFront origin uses TLSv1/1.1
- **Compliance**:
  - Missing data classification tags on some resources
  - Hardcoded compliance values ("None", "Confidential")

## 5. Technical Debt
- **Modularization**:
  - Single Lambda function handles all certificate operations
  - Mixed WAFv1/WAFv2 implementations
- **Hardcoding**:
  - Lambda code contains compressed Python
  - WAF IP ranges aren't parameterized
  - CloudFront origin configuration uses literals
- **Maintainability**:
  - No parameter validation
  - Inconsistent tagging strategy
  - Missing environment-specific configurations

## 6. Terraform Migration Complexity
Moderate complexity:
- Custom resources (DNSCertificate, CNAME) require equivalents
- Lambda deployment model differs between CFN and Terraform
- WAFv1 resources need migration to WAFv2
- S3 bucket policy syntax differs slightly
- CloudFront configuration structure varies

## 7. Recommended Migration Path
1. **Prerequisites**:
   - Establish Terraform state management
   - Create parameter mappings
   - Implement secrets management

2. **Core Infrastructure**:
   - Migrate S3 bucket with policy corrections
   - Convert Lambda + IAM role
   - Implement WAFv2 resources
   - Create CloudFront distribution

3. **Security**:
   - Replace custom certificate resource with Terraform ACM
   - Parameterize WAF rules
   - Add missing resource tagging

4. **Validation**:
   - Validate DNS propagation
   - Test WA

