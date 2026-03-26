/*
* # AWS dynamodb with resource table usage example
* Terraform module which creates SAF2.0 dynamodb with resource table in AWS.
* Dynamodb-table with global-replica cannot be created with "table_billing_mode" "PROVISIONED". 
* This is a known issue and is a bug with the aws-provider and reported in the below github link: 
* https://github.com/hashicorp/terraform-provider-aws/issues/13097
*/
#
# Filename    : modules/dynamodb/examples/dynamodb_global_table/main.tf
# Date        : 29 March 2022
# Author      : TCS
# Description : The Terraform usage example creates aws dynamodb tables in two regions and sets one of them as the global table. 

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
# uncomment the following lines to create kms klkey
# module "kms_key_us_west_2" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.1"
#   name        = var.kms_name
#   description = var.kms_description
#   aws_role    = local.aws_role
#   kms_role    = var.kms_role
#   tags        = merge(module.tags.tags, local.optional_tags)
# }

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key_us_east_1" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.1"

#   providers = {
#     aws = aws.us-east-1
#   }

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

# Customer Managed CMK's on DynamoDb Global Table replicas is not supported while using the 'dynamodb_global_table' module.
# Reference of the github links with the issue:
# https://github.com/hashicorp/terraform-provider-aws/issues/16358
# https://github.com/hashicorp/terraform-provider-aws/pull/18373
# Hence using the replica configuration block of dynamodb_table module.

module "dynamodb_table_us_west_2" {

  source = "../../"

  table_name                         = var.table_name
  hash_key                           = var.hash_key
  stream_enabled                     = var.stream_enabled
  stream_view_type                   = var.stream_view_type
  hash_range_key_attributes          = var.hash_range_key_attributes
  server_side_encryption_kms_key_arn = null #replace with module.kms_key_us_west_2.key_arn after key creation
  replica_kms_key_arn_us_east_1      = null #replace with module.kms_key_us_east_1.key_arn after key creation
  tags                               = merge(module.tags.tags, local.optional_tags)
  create_replica                     = var.create_replica

}

