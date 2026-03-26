data "aws_region" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_caller_identity" "current" {}

data "aws_arn" "sts" {
  arn = data.aws_caller_identity.current.arn
}
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# Data source for existing CloudFront distribution (only when we need domain name for Route53 records)
data "aws_cloudfront_distribution" "existing" {
  count = var.existing_cloudfront_distribution_arn != null ? 1 : 0
  id    = split("/", var.existing_cloudfront_distribution_arn)[1]
}
data "aws_route53_zone" "public_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = false
}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = true
}


data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "artifactory_repo_key" {
  name = var.ssm_parameter_artifactory_repo_key
}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}

# IMPORTANT: WAF Resources for CloudFront MUST be in us-east-1
# CloudFront is a global service that can ONLY use WAF Web ACLs created in us-east-1 region
# This applies to BOTH internal and external WAF configurations:
# - Internal WAF: Created by this module using aws.us_east_1 provider (see main.tf)
# - External WAF: Must exist in us-east-1 and parameter store must also be in us-east-1
# Regardless of where your other AWS resources are deployed, WAF for CloudFront must be us-east-1
data "aws_ssm_parameter" "external_waf" {
  count    = var.s3web_pge_waf == "external" ? 1 : 0
  provider = aws.us_east_1
  name     = var.ssm_parameter_external_waf_name
}

data "aws_wafv2_web_acl" "this" {
  count    = var.s3web_pge_waf == "external" ? 1 : 0
  provider = aws.us_east_1
  name     = data.aws_ssm_parameter.external_waf[0].value
  scope    = "CLOUDFRONT"
}