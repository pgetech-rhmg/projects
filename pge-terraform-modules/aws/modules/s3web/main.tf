/*
 * # AWS s3web module
 * #### For the latest guide check :  https://wiki.comp.pge.com/display/CCE/Terraform-S3Web
 * ```
 * # quickstart - steps:
 * # setup providers
 * provider "aws" {
 *   region = var.aws_region
 *   assume_role {
 *     role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
 *   }
 * }
 * provider "aws" {
 *   alias  = "r53"
 *   region = "us-east-1"
 *   assume_role {
 *     role_arn = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"
 *   }
 * }
 * provider "aws" {
 *   alias  = "us_east_1"
 *   region = "us-east-1"
 *   assume_role {
 *     role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
 *   }
 * }
 *
 * # invoke the module
 * module "s3web_html" {
 *   source  = "app.terraform.io/pgetech/s3web/aws"
 *   version = "0.1.0"   # update to the latest version as available in terraform registry
 *   # https://app.terraform.io/app/pgetech/registry/modules/private/pgetech/s3web/aws
 *   providers = {
 *     aws           = aws
 *     aws.us_east_1 = aws.us_east_1
 *     aws.r53       = aws.r53
 *   }
 *   tags                             = "<REQUIRED-TAGS>"
 *   bucket_name                      = "<YOUR-BUCKET-NAME>"
 *   custom_domain_name               = "<YOUR-CUSTOM-DOMAIN-NAME>"
 *   kms_key_arn                      = "<KMS-KEY-ARN-FOR-CODEPIPELINE>"
 *   s3web_type                       = "html"
 *   github_repo_url                  = "<YOUR-GITHUB-REPO-URL>"
 *   github_branch                    = "<YOUR-GITHUB-BRANCH>"
 *   secretsmanager_github_token      = "<SECRET-GITHUB-TOKEN-LOCATION>"
 *   secretsmanager_sonar_token       = "<SECRET-MANAGER-SONAR-TOKEN-LOCATION>"
 *   project_name                     = "<YOUR-CUSTOM-PROJECT-NAME>"
 * }
 * ```
 *
# NOTE: Usage instructions for object lock configuration in TFVARS file.
# Enabling object lock configuration.
# if object lock configuration is enabled, s3 Bucket versioning will automatically be "Enabled".
# Ref: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-overview.html#object-lock-bucket-config

object_lock_configuration = {
  mode  = "GOVERNANCE" #Valid values are GOVERNANCE and COMPLIANCE.
  days  = 1
  years = null
}




*/
#  Filename    : aws/modules/s3web/modules/s3web/main.tf
#  Date        : 09 Sep 2022
#  Author      : PGE
#  Description : creation of s3web module for s3 web
#

# IMPORTANT: WAF Resources for CloudFront MUST be in us-east-1
# CloudFront is a global service that can ONLY use WAF Web ACLs created in us-east-1 region
# This applies to BOTH internal and external WAF configurations:
# - Internal WAF: Created by this module using aws.us_east_1 provider (see WAF resources below)
# - External WAF: Must exist in us-east-1 and parameter store must also be in us-east-1
# Regardless of where your other AWS resources are deployed, WAF for CloudFront must be us-east-1

resource "random_pet" "s3web" {
  length = 2
}

locals {
  aws_region  = data.aws_region.current.name
  account_num = data.aws_arn.sts.account
  bucket_name = var.bucket_name == null ? "s3web-${random_pet.s3web.id}" : var.bucket_name
  github_org  = regex("https:\\/\\/github.com\\/(\\w+)\\/(.*).git", var.github_repo_url)[0]
  repo_name   = regex("https:\\/\\/github.com\\/(\\w+)\\/(.*).git", var.github_repo_url)[1]
  default_cors_rule_inputs = [{
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://${var.custom_domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
    id              = null
  }]
}

# This module sends logs to 3 different log buckets: S3 access logs, WAF logs, and CloudFront logs.
# If you are providing your own WAF log bucket, the bucket name MUST be prefixed with `aws-waf-logs-`
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration.html#log_destination_configs
locals {
  s3_log_bucket  = var.s3_log_bucket == null ? "ccoe-s3-accesslogs-spoke-${local.aws_region}-${local.account_num}" : var.s3_log_bucket
  s3_log_prefix  = var.s3_log_prefix == null ? local.account_num : var.s3_log_prefix
  waf_log_bucket = var.waf_log_bucket == null ? "arn:aws:firehose:us-east-1:${local.account_num}:deliverystream/aws-waf-logs-${local.account_num}-us-east-1" : var.waf_log_bucket
  cf_log_bucket  = var.cf_log_bucket == null ? "pge-${local.account_num}-cloudfront.s3.amazonaws.com" : var.cf_log_bucket
  cf_log_prefix  = var.cf_log_prefix == null ? local.account_num : var.cf_log_prefix
}

locals {
  namespace                 = "ccoe-tf-developers"
  principal_org_id          = "o-7vgpdbu22o"
  s3_origin_id              = "${local.bucket_name}-origin"
  subject_alternative_names = distinct(var.subject_alternative_names)
  custom_domain_name        = var.custom_domain_name
  base_domain_name          = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.custom_domain_name)[1]
  external_base_domain_list = ["alerts.pge.com", "ccare.pge.com", "cloudapi.pge.com", "dc.pge.com", "dcs.pge.com", "digitalcatalyst.pge.com", "io.pge.com", "ss-dev.pge.com", "ss.pge.com"]
  grants                    = var.grants
  object_lock_configuration = var.object_lock_configuration
  versioning                = local.object_lock_configuration == null ? var.versioning : "Enabled"
  default_root_object       = var.default_root_object
  cors_rule_inputs          = length(var.cors_rule_inputs) != 0 ? var.cors_rule_inputs : local.default_cors_rule_inputs
  wafv2_ip_set_name         = var.wafv2_ip_set_name != null ? var.wafv2_ip_set_name : "${local.bucket_name}-pge-ipset"
  codepipeline_name         = var.codepipeline_name != null ? var.codepipeline_name : "${local.bucket_name}-codepipeline"
  sg_name                   = var.sg_name != null ? var.sg_name : "${local.bucket_name}-codepipeline-sg"
  sg_description            = var.sg_description != null ? var.sg_description : "${local.bucket_name} codepipeline security group"
  is_html                   = var.s3web_type == "html" ? true : false
  is_angular                = var.s3web_type == "angular" ? true : false
  is_react                  = var.s3web_type == "react" ? true : false
  project_name              = var.project_name != null ? var.project_name : local.repo_name
  project_key               = var.project_key != null ? var.project_key : local.repo_name
  kms_key_arn               = var.kms_key_arn
  s3web_kms_key_arn         = var.s3web_cmk_enabled ? var.kms_key_arn : null
  s3web_cmk_enabled         = false
  block_public_policy       = true
  block_public_acls         = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
  web_acl_id                = var.s3web_pge_waf == "internal" ? aws_wafv2_web_acl.this[0].arn : data.aws_wafv2_web_acl.this[0].arn
  cf_function_code          = var.cf_function_code != null ? var.cf_function_code : file("${path.module}/cloudfront_functions/cloudfront_viewer_request.js")

  # CloudFront distribution configuration
  use_existing_cloudfront = var.existing_cloudfront_distribution_arn != null
  cloudfront_id           = local.use_existing_cloudfront ? split("/", var.existing_cloudfront_distribution_arn)[1] : aws_cloudfront_distribution.s3_distribution[0].id
  cloudfront_arn          = local.use_existing_cloudfront ? var.existing_cloudfront_distribution_arn : aws_cloudfront_distribution.s3_distribution[0].arn
  cloudfront_domain_name  = local.use_existing_cloudfront ? data.aws_cloudfront_distribution.existing[0].domain_name : aws_cloudfront_distribution.s3_distribution[0].domain_name
}



# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}


# Objects inside S3 buckets can only have 10 tags, so we'll only be allowing
# these 9 tags.
locals {
  s3web_object_tags = {
    AppID              = var.tags["AppID"]
    Environment        = var.tags["Environment"]
    DataClassification = var.tags["DataClassification"]
    CRIS               = var.tags["CRIS"]
    Notify             = var.tags["Notify"]
    Owner              = var.tags["Owner"]
    Compliance         = var.tags["Compliance"]
    tfc_wsname         = module.ws.name
    tfc_wsid           = module.ws.id
  }
}

# Always include or attach the BucketType as s3web as default for all s3web apps
locals {
  s3web_tags        = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  s3web_bucket_tags = merge(var.tags, { BucketType = "s3web" })
  s3web_tags_kms    = merge(var.tags, { tag-key = "kmskey-admin-${local.bucket_name}" })
}

# --- S3 Bucket ---
module "s3" {
  source                    = "app.terraform.io/pgetech/s3/aws"
  version                   = "0.1.3"
  bucket_name               = local.bucket_name
  versioning                = local.versioning
  kms_key_arn               = local.s3web_kms_key_arn
  tags                      = local.s3web_bucket_tags
  acl                       = null
  grants                    = local.grants
  object_lock_configuration = local.object_lock_configuration
  cors_rule_inputs          = local.cors_rule_inputs
  target_bucket             = local.s3_log_bucket
  target_prefix             = local.s3_log_prefix
  block_public_policy       = local.block_public_policy
  block_public_acls         = local.block_public_acls
  ignore_public_acls        = local.ignore_public_acls
  restrict_public_buckets   = local.restrict_public_buckets
  force_destroy             = true


  owner = {
    id = data.aws_canonical_user_id.current.id
  }

}


module "cloudfront_origin_access_control" {
  source  = "app.terraform.io/pgetech/cloudfront/aws//modules/cloudfront_origin_access_control"
  version = "0.1.2"
  count   = var.existing_cloudfront_distribution_arn == null ? 1 : 0

  cloudfront_oac_name             = var.cloudfront_oac_name
  cloudfront_oac_description      = var.cloudfront_oac_description
  cloudfront_oac_origin_type      = var.cloudfront_oac_origin_type
  cloudfront_oac_signing_behavior = var.cloudfront_oac_signing_behavior
  cloudfront_oac_signing_protocol = var.cloudfront_oac_signing_protocol
}
# # --- S3 Bucket Policy ---

module "s3_custom_bucket_policy" {
  source      = "app.terraform.io/pgetech/s3/aws//modules/s3_custom_bucket_policy"
  version     = "0.1.3"
  bucket_id   = module.s3.s3.id
  bucket_name = local.bucket_name
  policy      = data.aws_iam_policy_document.cloudfront_s3_readonly.json
  # Dependency is implicit through policy document that references local.cloudfront_id

}



# cloudfront s3 read only policy
data "aws_iam_policy_document" "cloudfront_s3_readonly" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/*"]


    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${local.account_num}:distribution/${local.cloudfront_id}"]


    }
  }


}

module "wafv2_ip_set" {
  source  = "app.terraform.io/pgetech/waf-v2/aws//modules/wafv2_ip_set_cloudfront"
  version = "0.1.1"
  providers = {
    aws = aws.us_east_1
  }
  count                           = var.s3web_pge_waf == "internal" ? 1 : 0
  wafv2_ip_set_name               = local.wafv2_ip_set_name
  wafv2_ip_set_description        = var.wafv2_ip_set_description
  wafv2_ip_set_ip_address_version = "IPV4"
  wafv2_ip_set_addresses          = local.allowed_ipv4_addresses
  tags                            = local.s3web_tags
}

# Internal WAF Web ACL - MUST be created in us-east-1 for CloudFront compatibility
# CloudFront can only use WAF Web ACLs created in us-east-1 regardless of your main region
resource "aws_wafv2_web_acl" "this" {
  provider    = aws.us_east_1
  count       = var.s3web_pge_waf == "internal" ? 1 : 0
  name        = "${local.bucket_name}-waf-web-acl-managed-rule"
  description = "${local.bucket_name} waf web acl managed rule."
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.bucket_name}-waf-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      allow {}
    }

    statement {

      ip_set_reference_statement {
        arn = module.wafv2_ip_set[0].ip_set_arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.bucket_name}-waf-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = local.s3web_tags

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${local.bucket_name}-waf-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  provider                = aws.us_east_1
  count                   = var.s3web_pge_waf == "internal" ? 1 : 0
  log_destination_configs = [local.waf_log_bucket]
  resource_arn            = aws_wafv2_web_acl.this[0].arn
}



# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.existing_cloudfront_distribution_arn == null ? 1 : 0

  origin {
    domain_name              = module.s3.s3.bucket_regional_domain_name
    origin_access_control_id = module.cloudfront_origin_access_control[0].cloudfront_origin_access_control_id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.bucket_name
  default_root_object = local.default_root_object

  logging_config {
    include_cookies = true
    bucket          = local.cf_log_bucket
    prefix          = local.cf_log_prefix
  }

  aliases = [local.custom_domain_name]

  default_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.s3_origin_id
    compress                 = true
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.spa_origin_policy[0].id
    viewer_protocol_policy   = "redirect-to-https"
    dynamic "function_association" {
      for_each = local.is_html ? [] : [1]
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.this[0].arn
      }
    }

  }
  price_class = var.cloudfront_priceclass
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }
  web_acl_id = local.web_acl_id
  tags       = local.s3web_tags

  viewer_certificate {
    acm_certificate_arn      = module.acm_public_certificate[0].acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
  depends_on = [
    module.acm_public_certificate,
    module.cloudfront_origin_access_control,
    module.wafv2_ip_set
  ]
}

# CloudFront Function , used resource here because the CF Terraform module currently is supporting js runtime 1.0 only, AWS also support 2.0
# Only create function when creating a new CloudFront distribution (not when using existing one)
resource "aws_cloudfront_function" "this" {
  count   = var.existing_cloudfront_distribution_arn == null && var.s3web_type != "html" ? 1 : 0
  name    = var.cf_function_name
  runtime = var.cf_function_runtime
  code    = local.cf_function_code
  comment = var.cf_function_comment
  publish = var.cf_function_publish
}



# Origin request policy for SPA
resource "aws_cloudfront_origin_request_policy" "spa_origin_policy" {
  count   = var.existing_cloudfront_distribution_arn == null ? 1 : 0
  name    = "${local.bucket_name}-spa-origin-policy"
  comment = "Origin request policy for SPA"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}



resource "aws_shield_protection" "this" {
  count        = var.advanced_aws_shield_protection ? 1 : 0
  name         = "${local.bucket_name}-aws-shield-protection"
  resource_arn = local.cloudfront_arn
  tags         = local.s3web_tags
  # Dependency is implicit through local.cloudfront_arn
}

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"
  count   = var.existing_cloudfront_distribution_arn == null ? 1 : 0
  providers = {
    aws     = aws.us_east_1
    aws.r53 = aws.r53
  }
  acm_subject_alternative_names = local.subject_alternative_names
  acm_domain_name               = local.custom_domain_name
  tags                          = local.s3web_tags

}

##########################################
## Create record
##########################################

module "external_records" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  count   = var.create_route53_records && var.s3web_pge_waf == "external" && contains(local.external_base_domain_list, local.base_domain_name) ? 1 : 0
  providers = {
    aws = aws.r53
  }
  zone_id = data.aws_route53_zone.public_zone.zone_id

  records = [
    {
      name    = local.custom_domain_name
      type    = "CNAME"
      ttl     = "300"
      records = [local.cloudfront_domain_name]
    }
  ]
  # Dependency is implicit through local.cloudfront_domain_name
}

module "records" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  count   = var.create_route53_records ? 1 : 0
  providers = {
    aws = aws.r53
  }
  zone_id = data.aws_route53_zone.private_zone.zone_id

  records = [
    {
      name    = local.custom_domain_name
      type    = "CNAME"
      ttl     = "300"
      records = [local.cloudfront_domain_name]

    }
  ]
  # Dependency is implicit through local.cloudfront_domain_name
}

resource "aws_s3_object" "index_html" {
  key           = "index.html"
  bucket        = module.s3.s3.id
  content       = "<!DOCTYPE html><html><body><h1>The Welcome to S3 Static Web Project https://${local.custom_domain_name} .</h1><p>page is the default web page that is presented when a website operator has installed the S3 Static Web hosted on the AWS, and either the static content is not yet pushed complete or a problem at the website itself is preventing the correct content from appearing.<br> Github Org : ${local.github_org} <br> Github Repo : ${var.github_repo_url} </br> Branch : ${var.github_branch} </p></body></html>"
  content_type  = "text/html"
  kms_key_id    = local.s3web_kms_key_arn
  force_destroy = true
  tags          = local.s3web_object_tags
  depends_on = [
    module.s3.s3

  ]
  lifecycle {
    ignore_changes = all
  }
}

module "codepipeline_angular" {
  source  = "app.terraform.io/pgetech/codepipeline_s3web/aws//modules/angular"
  version = "0.1.4"

  count                                   = local.is_angular ? 1 : 0
  codepipeline_name                       = local.codepipeline_name
  region                                  = data.aws_region.current.name
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token
  build_args1                             = var.build_args1
  cidr_egress_rules                       = var.cidr_egress_rules
  sg_name                                 = local.sg_name
  sg_description                          = local.sg_description
  s3_static_web_bucket_name               = module.s3.s3.id
  nodejs_version                          = var.nodejs_version
  project_root_directory                  = var.project_root_directory
  github_branch                           = var.github_branch
  project_unit_test_dir                   = var.project_unit_test_dir
  project_name                            = local.project_name
  project_key                             = local.project_key
  github_repo_url                         = var.github_repo_url
  subnet_ids                              = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id                                  = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token                      = var.secretsmanager_github_token
  artifactory_host                        = data.aws_ssm_parameter.artifactory_host.value
  sonar_host                              = data.aws_ssm_parameter.sonar_host.value
  artifactory_repo_key                    = data.aws_ssm_parameter.artifactory_repo_key.value
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token        = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  kms_key_arn                             = local.kms_key_arn
  pollchanges                             = var.pollchanges
  package_manager                         = var.package_manager
  nodejs_version_codescan                 = var.nodejs_version_codescan
  aws_cloudfront_distribution_id          = local.cloudfront_id
  environment_variables_codescan_stage    = var.environment_variables_codescan_stage
  environment_variables_codepublish_stage = var.environment_variables_codepublish_stage
  environment_variables_codebuild_stage   = var.environment_variables_codebuild_stage

  tags = local.s3web_tags
  depends_on = [
    aws_s3_object.index_html
  ]
}

module "codepipeline_html" {
  source  = "app.terraform.io/pgetech/codepipeline_s3web/aws"
  version = "0.1.4"
  count   = local.is_html ? 1 : 0

  codepipeline_name = local.codepipeline_name
  region            = data.aws_region.current.name

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token
  repo_name                               = local.repo_name

  encryption_key_id                       = local.kms_key_arn
  cidr_egress_rules                       = var.cidr_egress_rules
  sg_name                                 = local.sg_name
  sg_description                          = local.sg_description
  s3_static_web_bucket_name               = module.s3.s3.id
  s3_static_web_bucket_region             = module.s3.s3.region
  nodejs_version                          = var.nodejs_version
  project_root_directory                  = var.project_root_directory
  github_branch                           = var.github_branch
  project_unit_test_dir                   = var.project_unit_test_dir
  project_name                            = local.project_name
  project_key                             = local.project_key
  github_repo_url                         = var.github_repo_url
  subnet_ids                              = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id                                  = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token                      = var.secretsmanager_github_token
  artifactory_host                        = data.aws_ssm_parameter.artifactory_host.value
  sonar_host                              = data.aws_ssm_parameter.sonar_host.value
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token        = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  pollchanges                             = var.pollchanges
  nodejs_version_codescan                 = var.nodejs_version_codescan
  kms_key_arn                             = local.kms_key_arn
  aws_cloudfront_distribution_id          = local.cloudfront_id
  environment_variables_codescan_stage    = var.environment_variables_codescan_stage
  environment_variables_codepublish_stage = var.environment_variables_codepublish_stage

  tags = local.s3web_tags
  depends_on = [
    aws_s3_object.index_html
  ]
}

module "codepipeline_react" {
  source  = "app.terraform.io/pgetech/codepipeline_s3web/aws//modules/react"
  version = "0.1.4"

  count                                   = local.is_react ? 1 : 0
  codepipeline_name                       = local.codepipeline_name
  region                                  = data.aws_region.current.name
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token
  build_args1                             = var.build_args1
  cidr_egress_rules                       = var.cidr_egress_rules
  sg_name                                 = local.sg_name
  sg_description                          = local.sg_description
  s3_static_web_bucket_name               = module.s3.s3.id
  nodejs_version                          = var.nodejs_version
  project_root_directory                  = var.project_root_directory
  github_branch                           = var.github_branch
  project_unit_test_dir                   = var.project_unit_test_dir
  project_name                            = local.project_name
  project_key                             = local.project_key
  github_repo_url                         = var.github_repo_url
  subnet_ids                              = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id                                  = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token                      = var.secretsmanager_github_token
  artifactory_host                        = data.aws_ssm_parameter.artifactory_host.value
  sonar_host                              = data.aws_ssm_parameter.sonar_host.value
  artifactory_repo_key                    = data.aws_ssm_parameter.artifactory_repo_key.value
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token        = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  kms_key_arn                             = local.kms_key_arn
  pollchanges                             = var.pollchanges
  package_manager                         = var.package_manager
  nodejs_version_codescan                 = var.nodejs_version_codescan
  aws_cloudfront_distribution_id          = local.cloudfront_id
  environment_variables_codescan_stage    = var.environment_variables_codescan_stage
  environment_variables_codepublish_stage = var.environment_variables_codepublish_stage
  environment_variables_codebuild_stage   = var.environment_variables_codebuild_stage

  tags = local.s3web_tags
  depends_on = [
    aws_s3_object.index_html
  ]

}

#github webhook creation

module "codepipeline_webhook" {
  source            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version           = "0.1.4"
  count             = var.pollchanges != "true" ? 1 : 0
  codepipeline_name = local.codepipeline_name
  repo_name         = local.repo_name
  tags              = local.s3web_tags
}
