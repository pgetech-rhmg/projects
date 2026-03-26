/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/appconfig/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig deployment

locals {
  optional_tags = var.optional_tags
}

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

module "deployment" {
  source = "../../modules/deployment"

  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)

  application_id           = var.application_id
  strategy_id              = var.strategy_id
  configuration_profile_id = var.configuration_profile_id
  environment_id           = var.environment_id
  configuration_version    = var.configuration_version
  kms_key_id               = null # replace with: module.kms_key.key_arn
}