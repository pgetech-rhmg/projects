/*
 * # AWS CloudFront module Custom Origin example
*/
#
# Filename    : aws/modules/cloudfront/examples/custom_origin/main.tf
# Date        : 25 april 2022
# Author      : TCS
# Description : Terraform module example for cloudfront custom origin
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  user_data          = var.ec2_user_data

  # The local variable profile_id processes the value from module.encryption_profiles.field_level_encryption_profile_id and
  # converts it to list(string).
  profile_id = join("", [for index, value in module.encryption_profiles.field_level_encryption_profile_id : value])
  # The local variable encryption_config_id processes the value from module.encryption_configurations.field_level_encryption_config_id and
  # converts it to list(string).
  encryption_config_id = join("", [for index, value in module.encryption_configurations.field_level_encryption_config_id : value])
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
/* module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = var.kms_name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, local.optional_tags)
} */


module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.subnet_id3_name
}

data "aws_ssm_parameter" "golden_ami" {
  name = var.golden_ami_name
}

#########################################
# Create CloudFront
#########################################

module "cloudfront" {

  source = "../../modules/cloudfront_custom_origin"

  comment_cfd = var.comment_cfd

  default_root_object   = var.default_root_object
  enabled               = var.enabled
  http_version          = var.http_version
  custom_error_response = var.custom_error_response
  web_acl_id            = module.wafv2_web_acl.arn

  df_cache_behavior_allowed_methods           = var.df_cache_behavior_allowed_methods
  df_cache_behavior_cached_methods            = var.df_cache_behavior_cached_methods
  df_cache_behavior_viewer_protocol_policy    = var.df_cache_behavior_viewer_protocol_policy
  df_cache_behavior_target_origin_id          = var.df_cache_behavior_target_origin_id
  df_cache_behavior_field_level_encryption_id = local.encryption_config_id

  function_association = [{
    event_type   = var.event_type
    function_arn = module.cloudfront_function.cloudfront_function_arn
  }]

  logging_config = [{
    bucket = "${var.log_bucket_name}.s3.amazonaws.com"
  }]

  forwarded_values = var.forwarded_values

  origin = [{
    origin_id   = var.origin_id
    domain_name = module.alb.lb_dns_name
    custom_origin_config = [{
      https_port             = var.origin_https_port
      origin_protocol_policy = var.origin_protocol_policy
      origin_ssl_protocols   = var.origin_ssl_protocols
    }]
    custom_header = [{
      name  = var.custom_header_name
      value = var.custom_header_value
    }]
    origin_shield = [{
      enabled              = var.origin_shield_enabled
      origin_shield_region = var.origin_shield_region
    }]
  }]

  geo_restriction    = var.geo_restriction
  viewer_certificate = var.viewer_certificate
  tags               = merge(module.tags.tags, local.optional_tags)

  #####################################################################################

  cf_monitoring_subscription = [{
    distribution_id                      = module.cloudfront.cloudfront_distribution_id
    realtime_metrics_subscription_status = var.realtime_metrics_subscription_status
  }]

  ####################################################################################

  #aws_cloudfront_realtime_log_config
  cf_realtime_log_config = [{
    name          = var.realtime_log_config_name
    sampling_rate = var.realtime_log_config_sampling_rate
    fields        = var.realtime_log_config_fields
    endpoint = [{
      stream_type = var.realtime_log_config_stream_type
      kinesis_stream_config = [{
        role_arn   = module.aws_iam_role.arn
        stream_arn = aws_kinesis_stream.test_stream.arn
      }]
    }]
  }]
}

#############################################################
#IAM role allows to send real-time log data to the Kinesis data stream.
module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.role_name
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/log_config_iam_policy.json", { arn = aws_kinesis_stream.test_stream.arn })]
}

# This resource is used for passing the stream arn to the resource cloudfront real time log config
resource "aws_kinesis_stream" "test_stream" {
  name                = var.kinesis_stream_name
  shard_count         = var.kinesis_stream_shard_count
  retention_period    = var.kinesis_stream_retention_period
  shard_level_metrics = var.kinesis_stream_shard_level_metrics
  stream_mode_details {
    stream_mode = var.kinesis_stream_mode
  }

  tags = module.tags.tags
}

#############################################################

#With CloudFront Function, we can provide JavaScript functions through the variable cf_function_code.
module "cloudfront_function" {
  source = "../../modules/cloudfront_function"

  cf_function_name = var.cf_function_name
  cf_function_code = file("${path.module}/cloudfront_function.js")
}

##############################################################

module "s3_cf_log_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.log_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  acl         = var.log_bucket_acl
  policy      = templatefile("${path.module}/${var.log_policy}", { bucket = var.log_bucket_name })
  tags        = merge(module.tags.tags, local.optional_tags)
}


##############################################################

module "key_management" {
  source = "../../modules/key_management"

  #aws_cloudfront_key_group
  cf_key_group = [{
    items = [module.key_management.public_key_id["0"]]
    name  = var.key_group_name
  }]

  #aws_cloudfront_public_key
  #The public key is generated by using an ec2 instance and used the value of that public key to create the file 'public_key.pem'.
  cf_public_key = [{
    comment     = var.public_key_comment
    encoded_key = file("${path.module}/public_key.pem")
  }]
}

###############################################################

module "encryption_profiles" {
  source = "../../modules/field_level_encryption_profile"

  # #aws_cloudfront_field_level_encryption_profile
  cf_field_level_encryption_profile = [{
    name = var.encryption_profile_name
    encryption_entities = [{
      items = [{
        public_key_id = module.key_management.public_key_id["0"]
        provider_id   = var.encryption_profile_provider_id
        field_patterns = [{
          items = var.encryption_profile_items
        }]
      }]
    }]
  }]
}

##################################################################

module "encryption_configurations" {
  source = "../../modules/field_level_encryption_config"

  # #aws_cloudfront_field_level_encryption_config 
  cf_field_level_encryption_config = [{
    content_type_profile_config = [{
      forward_when_content_type_is_unknown = var.encryption_config_forward_when_content_type_is_unknown
      content_type_profiles = [{
        items = [{
          content_type = var.encryption_config_content_type
          format       = var.encryption_config_format
          profile_id   = local.profile_id
        }]
      }]
    }]
    query_arg_profile_config = [{
      forward_when_query_arg_profile_is_unknown = var.encryption_config_forward_when_query_arg_profile_is_unknown
    }]
  }]
}

####################################################################

module "cloudfront_policy" {
  source = "../../modules/cloudfront_policy"

  #aws_cloudfront_cache_policy
  cache_policy = var.cache_policy

  #aws_cloudfront_response_headers_policy
  response_headers_policy = var.response_headers_policy

  #aws_cloudfront_origin_request_policy
  origin_request_policy = var.origin_request_policy
}

#########################################
#  WAFv2
#########################################

module "wafv2_web_acl" {
  source  = "app.terraform.io/pgetech/waf-v2/aws"
  version = "0.1.1"

  providers = {
    aws = aws.east
  }

  webacl_name            = var.webacl_name
  webacl_description     = var.webacl_description
  tags                   = merge(module.tags.tags, local.optional_tags)
  request_default_action = var.request_default_action
  managed_rules          = var.managed_rules

  redacted_fields = var.redacted_fields

  cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
  sampled_requests_enabled   = var.sampled_requests_enabled
  metric_name                = var.metric_name

  log_destination_arn = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

# This resource is used for passing the kinesis firehose delivery stream arn to the module wafv2_web_acl
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  provider = aws.east

  name        = var.aws_kinesis_firehose_delivery_stream_name
  destination = var.kinesis_firehose_delivery_stream_destination

  extended_s3_configuration {
    role_arn   = module.aws_iam_role_kinesis.arn
    bucket_arn = module.aws_s3_bucket.arn
  }

  tags = module.tags.tags
}

module "aws_s3_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.waf_v2_logging_kinesis_s3_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "aws_iam_role_kinesis" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.kinesis_iam_role_name
  tags        = merge(module.tags.tags, local.optional_tags)
  policy_arns = var.policy_arns
  aws_service = var.aws_service
}

#########################################
# Create Application Load Balancer
#########################################

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.2"

  alb_name    = var.alb_name
  bucket_name = aws_s3_bucket.bucket_alb_logs.bucket

  security_groups = [module.alb_security_group.sg_id]
  subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id3.value]
  tags            = merge(module.tags.tags, local.optional_tags)

  ###############listener###################
  lb_listener_https = var.lb_listener_https

  ###############target###################

  lb_target_group = [
    {
      name        = var.target_group_name
      target_type = var.target_group_target_type
      port        = var.target_group_port
      protocol    = var.target_group_protocol
      targets = {
        ec2 = {
          target_id = module.ec2.id
          port      = var.targets_port
        }
      }
      health_check = [{ enabled = true }]
      stickiness = [{ type = "lb_cookie"
      enabled = false }]
    }
  ]
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

#  Instead of using PG&E s3 module, here we use aws_s3_bucket terraform resource because 
#  alb logs cannot be written to a kms-cmk encrypted s3 bucket.
#  So standard encryption is used for the s3 bucket.
#  https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html

resource "aws_s3_bucket" "bucket_alb_logs" {
  bucket = var.alb_s3_bucket_name
  tags   = merge(module.tags.tags, local.optional_tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_alb_encryption" {
  bucket = aws_s3_bucket.bucket_alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "s3_default" {
  bucket = aws_s3_bucket.bucket_alb_logs.id
  policy = templatefile("${path.module}/${var.policy}", { bucket_name = var.alb_s3_bucket_name
    account_num = data.aws_caller_identity.current.account_id
  aws_role = var.aws_role })
}

module "alb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.alb_sg_name
  description = var.alb_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "ec2_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  security_group_ingress_rules = [{
    from                     = 80,
    to                       = 80,
    protocol                 = "tcp",
    source_security_group_id = module.alb_security_group.sg_id,
    description              = "CCOE Ingress rules",
    },
    {
      from                     = 443,
      to                       = 443,
      protocol                 = "tcp",
      source_security_group_id = module.alb_security_group.sg_id,
      description              = "CCOE Ingress rules",
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.2"

  name                   = var.ec2_name
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group.sg_id]

  user_data_base64 = base64encode(local.user_data)

  tags = merge(module.tags.tags, local.optional_tags)
}