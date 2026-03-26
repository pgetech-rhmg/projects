/*
* # AWS dynamodb with resource table usage example
* Terraform module which creates SAF2.0 dynamodb with resource table in AWS.
*/
#
# Filename    : modules/dynamodb/examples/dynamodb_table_kinesis_streaming/main.tf
# Date        : 29 March 2022
# Author      : TCS
# Description : The Terraform usage example creates aws dynamodb with resource table and kinesis streaming


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
  aws_role           = var.aws_role
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.1"
#   name        = var.kms_name
#   description = var.kms_description
#   aws_role    = local.aws_role
#   kms_role    = var.kms_role
#   tags        = merge(module.tags.tags, local.optional_tags)
# }

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

module "dynamodb_table" {
  source                             = "../../"
  table_name                         = var.table_name
  hash_key                           = var.hash_key
  range_key                          = var.range_key
  hash_range_key_attributes          = var.hash_range_key_attributes
  ttl_enabled                        = var.ttl_enabled
  ttl_attribute_name                 = var.ttl_attribute_name
  server_side_encryption_kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  stream_enabled                     = var.stream_enabled
  stream_view_type                   = var.stream_view_type
  local_secondary_indexes            = var.local_secondary_indexes
  tags                               = merge(module.tags.tags, local.optional_tags)

}

module "kinesis_streaming_destination" {
  source = "../../modules/dynamodb_kinesis_streaming"
  depends_on = [
    module.dynamodb_table
  ]
  table_name = var.table_name
  stream_arn = aws_kinesis_stream.kinesis_stream.arn

}


resource "aws_kinesis_stream" "kinesis_stream" {
  name        = var.kinesis_stream_name
  shard_count = var.kinesis_stream_shard_count
  tags        = merge(module.tags.tags, local.optional_tags)
}