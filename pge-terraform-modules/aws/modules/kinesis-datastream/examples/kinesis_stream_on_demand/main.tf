/*
 * # AWS Kinesis Stream  User module example
*/
#
#  Filename    : aws/modules/kinesis-datastream/examples/kinesis_stream_provisioned/main.tf
#  Date        : 30 Aug 2022
#  Author      : TCS
#  Description : The terraform module creates a kinesis stream

locals {
  common_name = "${var.name}-${random_string.name.result}"
  Order       = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name     = local.common_name
#   aws_role = var.aws_role
#   kms_role = var.kms_role
#   tags     = merge(module.tags.tags, var.optional_tags)
# }

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
  Order              = local.Order
}

##############################################################
# Kinesis data stream
##############################################################

module "kinesis_stream" {
  source = "../../"

  name = local.common_name

  stream_mode = {
    shard_count         = var.stream_mode.shard_count
    stream_mode_details = var.stream_mode.stream_mode_details
  }

  kms_key_id      = null # replace with module.kms_key.key_arn, after key creation
  timeouts        = var.timeouts
  tags            = merge(module.tags.tags, var.optional_tags)
  encryption_type = var.encryption_type
}


##############################################################
# Kinesis data stream consumer
##############################################################

module "kinesis_stream_consumer" {
  source = "../../modules/kinesis_stream_consumer"

  name       = local.common_name
  stream_arn = module.kinesis_stream.arn
}