/*
 * # AWS AppConfig simple example
 *
 * #### This example demonstrates a rapid, simple AppConfig use case that has a single module that wraps
 * submodules for a highly simplified configuration, but is restricted in flexibility.
 * 
 * You may also reference the appconfig_modular example for a full and modularized use case that allows
 * for complete control over your AppConfig service.
*/
#
#  Filename    : aws/modules/appconfig/examples/appconfig_simple/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module demonstrates a basic AppConfig use case.


data "aws_caller_identity" "this" {}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.0"
#   name        = var.kms_name
#   description = var.kms_description
#   tags        = module.tags.tags
#   aws_role    = var.aws_role
#   kms_role    = var.kms_role
# }

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
}

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
module "appconfig_simple" {
  source = "../../"

  name                       = var.name
  description                = var.description
  config_profile_name        = var.config_profile_name
  config_profile_description = var.config_profile_description
  env_name                   = var.env_name
  env_description            = var.env_description
  env_monitors               = var.env_monitors
  hosted_config_content      = var.hosted_config_content
  hosted_config_description  = var.hosted_config_description
  hosted_config_content_type = var.hosted_config_content_type
  kms_key_id                 = null # replace with module.kms_key.kms_key_arn for encryption

  tags = merge(module.tags.tags, local.optional_tags)
}