###############################################################################
# Tags
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id     = var.aws_account_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}


###############################################################################
# Certs — public ACM cert in us-east-1 for CloudFront
###############################################################################

module "acm_web" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = "public"
  tags                  = module.tags.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}


###############################################################################
# WAF — restricts CloudFront to PG&E source IPs only
#
# CloudFront WAFv2 must live in us-east-1 with scope = CLOUDFRONT.
# IMPORTANT: addresses must be PG&E's PUBLIC egress IP ranges, not RFC1918 —
# CloudFront's edge sees the corporate NAT egress IP, not the user's internal IP.
###############################################################################

resource "aws_wafv2_ip_set" "pge" {
  provider           = aws.us_east_1
  name               = "pge-epic-${var.app_name}-web-${var.environment}-pge-allowlist"
  description        = "PGE source IPs allowed to reach the CloudFront distribution"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_cidrs
  tags               = module.tags.tags
}

resource "aws_wafv2_web_acl" "web" {
  provider = aws.us_east_1
  name     = "pge-epic-${var.app_name}-web-${var.environment}"
  scope    = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AllowPGE"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.pge.arn
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowPGE"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "pge-epic-${var.app_name}-web-${var.environment}"
  }

  tags = module.tags.tags
}


###############################################################################
# S3
###############################################################################

module "s3_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "${var.app_name}-web"
  environment                = var.environment
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = var.access_log_prefix
  custom_bucket_name         = var.custom_bucket_name
  bucket_policy_json         = var.bucket_policy_json
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = var.enable_public_access_block
  enable_versioning          = var.enable_versioning
  force_destroy              = var.force_s3_destroy
  kms_key_arn                = var.kms_key_arn
  lifecycle_rules            = var.lifecycle_rules
  object_ownership           = var.object_ownership
  sse_algorithm              = var.sse_algorithm
}


###############################################################################
# CloudFront
###############################################################################

module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  app_name                    = "${var.app_name}-web"
  environment                 = var.environment
  bucket_name                 = module.s3_web.bucket_name
  bucket_arn                  = module.s3_web.bucket_arn
  bucket_regional_domain_name = module.s3_web.bucket_regional_domain_name
  price_class                 = var.price_class
  custom_domain_aliases       = var.custom_domain_aliases
  custom_acm_certificate_arn  = module.acm_web.certificate_arn
  cors_allowed_origins        = var.cors_allowed_origins
  web_acl_id                  = aws_wafv2_web_acl.web.arn

  tags = merge(module.tags.tags, { Name = "pge-epic-${var.app_name}-web-${var.environment}-cloudfront" })
}


###############################################################################
# Route53 — private zone only (no public A record)
###############################################################################

module "aws_route53_record_web_private" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                = var.private_hosted_zone_id
  domain_name            = var.domain_name
  record_type            = "A"
  target_domain_name     = module.cloudfront.distribution_domain_name
  target_zone_id         = "Z2FDTNDATAQYW2"
  evaluate_target_health = false
}
