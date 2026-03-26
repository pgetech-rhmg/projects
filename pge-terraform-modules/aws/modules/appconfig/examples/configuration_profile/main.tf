/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/configuration_profile/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig configuration profile

locals {
  optional_tags = var.optional_tags
}

data "aws_caller_identity" "this" {}

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

# Application with environments and monitors
module "configuration_profile" {
  source = "../../modules/configuration_profile"

  name        = var.name
  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)

  application_id = var.application_id
  kms_key_id     = null # replace with module.kms_key.key_arn
}