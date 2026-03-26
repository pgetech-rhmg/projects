/*
 * # AWS Kinesis firehose  User module example
*/
#
#  Filename    : aws/modules/kinesis-firehose/examples/elasticsearch_destination/main.tf
#  Date        : 26 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates a kinesis firehose 

locals {
  common_name = "${var.name}-${random_string.name.result}"
  iam_policy = templatefile(
    "${path.module}/kinesis_firehose_iam_policy.json",
    {
      account_num = var.account_num,
      aws_region  = var.aws_region
  })
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.common_name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, var.optional_tags)
}

data "aws_caller_identity" "current" {}

# Supporting Resource
data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_subnet" "elasticsearch1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "elasticsearch2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "elasticsearch3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

# The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
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
  Order              = var.Order
}

###################################################################################
# Kinesis firehose - elasticsearch destination
###################################################################################

module "elasticsearch_firehose" {
  source = "../../"

  name        = local.common_name
  destination = "elasticsearch"

  kinesis_source_server_side_encryption = {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn           = var.kinesis_stream_role_arn
    key_arn            = module.kms_key.key_arn
  }

  elasticsearch_configuration = {
    domain_arn       = aws_elasticsearch_domain.test_cluster.arn
    cluster_endpoint = var.cluster_endpoint
    index_name       = var.index_name
    role_arn         = module.firehose_aws_iam_role.arn

    buffering_interval    = var.buffering_interval
    buffering_size        = var.buffering_size
    index_rotation_period = var.index_rotation_period
    s3_backup_mode        = var.s3_backup_mode
    type_name             = var.type_name
    retry_duration        = var.retry_duration
    log_group_name        = module.log_group.cloudwatch_log_group_name
    log_stream_name       = var.elasticsearch_log_stream_name

    vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
    vpc_config_security_group_ids = [module.security_group_elasticsearch.sg_id]
    vpc_config_role_arn           = module.firehose_aws_iam_role.arn

    s3_configuration = {
      role_arn    = module.firehose_aws_iam_role.arn
      bucket_arn  = module.s3.arn
      kms_key_arn = module.kms_key.key_arn

      prefix              = var.prefix
      buffer_size         = var.s3_buffer_size
      buffer_interval     = var.s3_buffer_interval
      compression_format  = var.compression_format
      error_output_prefix = var.error_output_prefix
      log_group_name      = module.log_group.cloudwatch_log_group_name
      log_stream_name     = var.s3_log_stream_name
    }

    processing_configuration = {
      enabled    = var.processing_configuration_enabled,
      processors = var.processing_configuration_processors
    }

  }

  tags = merge(module.tags.tags, var.optional_tags)
}

module "firehose_iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name   = local.common_name
  path   = var.path
  policy = [local.iam_policy]
  tags   = merge(module.tags.tags, var.optional_tags)
}

module "firehose_aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.common_name
  aws_service = var.aws_service
  # Customer Managed Policy
  policy_arns = [module.firehose_iam_policy.arn]
  tags        = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.firehose_iam_policy
  ]

}

module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name_prefix = local.common_name
  tags        = merge(module.tags.tags, var.optional_tags)
}

# log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "s3_log_stream" {
  name           = var.s3_log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

# log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "elasticsearch_s3_log_stream" {
  name           = var.elasticsearch_log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.common_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.template_file.s3_custom_bucket_policy.rendered
  tags        = merge(module.tags.tags, var.optional_tags)
}

data "template_file" "s3_custom_bucket_policy" {
  template = file("${path.module}/s3_bucket_user_policy.json")
  vars = { bucket_name = local.common_name,
    account_num = var.account_num
  }
}

module "security_group_elasticsearch" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.common_name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.elasticsearch1.cidr_block, data.aws_subnet.elasticsearch2.cidr_block, data.aws_subnet.elasticsearch3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.elasticsearch1.cidr_block, data.aws_subnet.elasticsearch2.cidr_block, data.aws_subnet.elasticsearch3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

##############################################################################
# Elasticsearch resource
###############################################################################

data "aws_region" "current" {}


# There is no PG&E elasticsearch module available, hence using resource
resource "aws_elasticsearch_domain" "test_cluster" {

  domain_name = var.domain_name

  cluster_config {
    instance_count         = var.instance_count
    zone_awareness_enabled = var.zone_awareness_enabled
    instance_type          = var.instance_type
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.volume_size
  }

  vpc_options {
    subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
    security_group_ids = [module.security_group_elasticsearch.sg_id]
  }

  access_policies = <<CONFIG
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "es:*",
              "Principal": "*",
              "Effect": "Allow",
              "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
          }
      ]
  }
  CONFIG

  tags = merge(module.tags.tags, var.optional_tags)
}