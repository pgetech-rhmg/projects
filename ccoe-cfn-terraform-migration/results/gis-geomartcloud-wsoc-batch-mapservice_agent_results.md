# Repository Assessment: gis-geomartcloud-wsoc-batch-mapservice

## 1. Overview
The repository contains a CloudFormation template for deploying ArcGIS Enterprise Server 10.8.1 on Windows EC2 instances with autoscaling and Elastic Load Balancing. Includes custom Lambda for ACM certificate automation and Route53 DNS integration.

## 2. Architecture Summary
- **Core Infrastructure**: Windows EC2 instances deployed via AutoScaling Group (min 2, max 4) with ArcGIS Server software
- **Networking**: Internal Application Load Balancer (ALB) with HTTPS listener (port 443) across 3 private subnets
- **Security**: Security groups with ingress rules for BMC Discovery, FSx, SQL Server, and ArcGIS services
- **Automation**: Custom Lambda function handles ACM certificate creation/validation using Route53
- **Observability**: No explicit logging/monitoring configurations detected

## 3. Identified Resources
- EC2::SecurityGroup (rELBSecurityGroup)
- ElasticLoadBalancingV2::LoadBalancer (rELB)
- ElasticLoadBalancingV2::Listener (rELBListener)
- ElasticLoadBalancingV2::TargetGroup (rELBTargetGroup)
- AutoScaling::AutoScalingGroup (rAutoScalingGroup)
- AutoScaling::LaunchConfiguration (rLaunchConfig)
- Lambda::Function (rCustomAcmCertificateLambda)
- IAM::Role (rCustomAcmCertificateLambdaExecutionRole)
- Custom::DNSCertificate (rGeneratedCertificate)
- Custom::CNAME (rRoute53CNAMERecord)

## 4. Issues & Risks
- **Security Group Exposure**: 
  - Overly permissive ingress rules (e.g., 10.0.0.0/8 allows all RFC1918 space)
  - Public IP addresses hardcoded in security group rules
  - Missing egress rules (default deny-all may block required outbound traffic)
- **Hardcoded Values**: 
  - AMI ID hardcoded instead of using SSM parameter lookup
  - Multiple magic numbers in health checks/timeouts
- **IAM Policy Scope**: 
  - Lambda execution role has acm:* and route53:* permissions
  - Uses wildcard resources in ACM policy statements
- **Missing Deletion Protection**: 
  - ALB has deletion_protection disabled
- **No Logging**: 
  - ALB access logs disabled
  - No CloudWatch logging for Lambda function

## 5. Technical Debt
- **Parameter Sprawl**: 26 parameters with inconsistent naming conventions
- **Tight Coupling**: 
  - Security group references hardcoded in multiple resources
  - Lambda function tied to specific certificate logic
- **Environment Handling**: 
  - Uses "dev" default environment
  - No clear separation between environment-specific values
- **Resource Naming**: 
  - Uses stack ID fragments instead of consistent naming patterns

## 6. Terraform Migration Complexity
Moderate to High. Challenges include:
- Custom Lambda resource would require AWS provider equivalent
- SSM parameter lookup syntax differs between CFN and Terraform
- Security group rules would need restructuring

## 7. Recommended Migration Path
Not Observed

