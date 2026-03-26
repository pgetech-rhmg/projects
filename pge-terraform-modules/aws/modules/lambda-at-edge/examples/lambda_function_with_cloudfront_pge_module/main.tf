/*
 * # AWS Lambda@edge module with Cloudfront distribution example. This example is using Cloudfront PGE module.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/lambda-at-edge/examples/lambda_function_with_cloudfront_pge_module/main.tf
#  Date        : 20 September 2022
#  Author      : PGE
#  Description : creation of cloudfront distribution using PGE module and lambda@edge module
#

locals {
  s3_origin_id              = "${var.bucket_name}-origin"
  bucket_name               = "${var.bucket_name}-${random_pet.ledge.id}"
  r53_account_num           = var.account_num_r53
  r53_aws_role              = var.aws_r53_role
  r53_region                = var.aws_r53_region
  custom_domain_name        = var.custom_domain_name
  base_domain_name          = regex("[a-zA-Z0-9_%+-]+\\.(.*)", var.custom_domain_name)[0]
  aws_role                  = var.aws_role
  kms_role                  = var.kms_role
  grants                    = var.grants
  object_lock_configuration = var.object_lock_configuration
  cors_rule_inputs          = var.cors_rule_inputs
  target_bucket             = "${var.bucket_name}-log-bucket"
  target_prefix             = "${var.bucket_name}/"
  optional_tags             = var.optional_tags
  lambda_policy_name        = var.lambda_policy_name
  lambda_policy_path        = var.lambda_policy_path
  lambda_policy_description = var.lambda_policy_description
  Order                     = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

resource "random_pet" "ledge" {
  length = 2
}

data "aws_canonical_user_id" "current" {}

# data "aws_route53_zone" "public_zone" {
#   provider     = aws.r53
#   name         = local.base_domain_name
#   private_zone = false
# }

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = true
}

######################################################################################

module "aws_iam_role" {
  source                 = "app.terraform.io/pgetech/iam/aws"
  version                = "0.1.1"
  name                   = "kmskey-admin-${local.bucket_name}"
  tags                   = merge(module.tags.tags, local.optional_tags)
  policy_arns            = ["arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"]
  trusted_aws_principals = ["arn:aws:iam::${var.account_num}:root"]
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.0.10"
#   name        = var.kms_name
#   kms_role    = local.kms_role
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   policy = templatefile("${path.module}/${var.kms_template_file_name}", {
#     account_num = var.account_num
#   })
# }

#########################################
# S3 buckets
#########################################

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name               = local.bucket_name
  kms_key_arn               = null # replace with module.kms_key.key_arn after key creation
  tags                      = merge(module.tags.tags, local.optional_tags)
  grants                    = local.grants
  object_lock_configuration = local.object_lock_configuration
  cors_rule_inputs          = local.cors_rule_inputs
  acl                       = null
  target_bucket             = local.target_bucket
  target_prefix             = local.target_prefix
  owner = {
    id = data.aws_canonical_user_id.current.id
  }
  versioning = "Enabled"
  depends_on = [
    aws_s3_bucket.log_bucket,
    aws_s3_bucket_acl.log_bucket_acl
  ]

}

resource "aws_s3_bucket" "log_bucket" {
  bucket = local.target_bucket
  tags   = merge(module.tags.tags, local.optional_tags)
}

# Provides an s3 bucket object ownership.
resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
  depends_on = [
    aws_s3_bucket_ownership_controls.default
  ]
}

resource "aws_s3_object" "index_html" {
  key          = "index.html"
  bucket       = module.s3.id
  source       = "${path.module}/${var.static_content}"
  content_type = "text/html"
  kms_key_id   = null # replace with module.kms_key.key_arn after key creation
  tags         = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create CloudFront
#########################################
module "cloudfront" {
  source  = "app.terraform.io/pgetech/cloudfront/aws//modules/cloudfront_custom_origin"
  version = "0.1.1"

  comment_cfd = var.comment_cfd

  default_root_object   = var.default_root_object
  enabled               = var.enabled
  http_version          = var.http_version
  custom_error_response = var.custom_error_response
  web_acl_id            = null

  df_cache_behavior_allowed_methods        = var.df_cache_behavior_allowed_methods
  df_cache_behavior_cached_methods         = var.df_cache_behavior_cached_methods
  df_cache_behavior_viewer_protocol_policy = var.df_cache_behavior_viewer_protocol_policy
  df_cache_behavior_target_origin_id       = local.s3_origin_id
  df_cache_behavior_min_ttl                = 0
  df_cache_behavior_default_ttl            = 3600
  df_cache_behavior_max_ttl                = 86400

  aliases = [local.custom_domain_name]

  logging_config = [{
    include_cookies = false
    bucket          = aws_s3_bucket.log_bucket.bucket_domain_name
    prefix          = local.bucket_name
  }]

  forwarded_values = var.forwarded_values
  price_class      = "PriceClass_200"

  origin = [{
    origin_id            = local.s3_origin_id
    domain_name          = module.s3.s3.bucket_domain_name
    custom_origin_config = []

    custom_header = [{
      name  = var.custom_header_name
      value = var.custom_header_value
    }]

    origin_shield = [{
      enabled              = var.origin_shield_enabled
      origin_shield_region = var.origin_shield_region
    }]
  }]

  lambda_function_association = [{
    event_type   = var.lambda_event_type
    lambda_arn   = module.lambda_edge_function.lambda_qualified_arn
    include_body = false
  }]


  viewer_certificate = [{
    acm_certificate_arn      = module.acm_public_certificate.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }]

  geo_restriction = var.geo_restriction
  tags            = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.lambda_edge_function,
    module.acm_public_certificate
  ]
}

#############################################################

module "cloudfront_oai" {
  source  = "app.terraform.io/pgetech/cloudfront/aws//modules/origin_access_identity"
  version = "0.1.1"

  comment_cf_oai = var.comment_cf_oai
}

##########################################
## Create SSL certificate
##########################################

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_domain_name = local.custom_domain_name
  tags            = merge(module.tags.tags, local.optional_tags)
}

##########################################
## Create route-53 record
##########################################

module "records" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  providers = {
    aws = aws.r53
  }
  zone_id = data.aws_route53_zone.private_zone.zone_id # private zone id

  records = [
    {
      name    = local.custom_domain_name
      type    = "CNAME"
      ttl     = "300"
      records = [module.cloudfront.cloudfront_distribution_domain_name]
    }
  ]
}

######################################################################################

######################################################
# IAM policies for the Lambda@edge function
######################################################

data "aws_iam_policy_document" "lambda_edge_exec_role_policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "${local.lambda_policy_name}-${random_pet.ledge.id}"
  path        = local.lambda_policy_path
  description = local.lambda_policy_description
  policy      = [data.aws_iam_policy_document.lambda_edge_exec_role_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create Lambda Function
#########################################

module "lambda_edge_function" {
  source = "../../"

  providers = {
    aws = aws.east
  }

  function_name              = "${var.function_name}-${random_pet.ledge.id}"
  iam_name                   = "${var.iam_name}-${random_pet.ledge.id}"
  policy_arns                = concat(var.policy_arns_list, [module.iam_policy.arn])
  description                = var.description
  runtime                    = var.runtime
  local_zip_source_directory = "${path.module}/${var.local_zip_source_directory}"
  tags                       = merge(module.tags.tags, local.optional_tags)
  handler                    = var.handler
}