/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 parameters in SSM parameter-store in AWS
*/

# Filename    : modules/ssm/main.tf
# Date        : 24 January 2024
# Author      : Ryan Avendano (r1av@pge.com)
# Description : The example code creates SAF2.0 parameters in SSM parameter-store in AWS used for custom Cost Anomaly configuration
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
  aws_role           = var.aws_role
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

module "custom_email_address" {
  source = "../../"
  name   = "/CostAnomaly/CustomEmailAddress"
  value  = var.custom_email_address_value
  tags   = merge(module.tags.tags, local.optional_tags)
}

module "custom_threshold" {
  source = "../../"
  name   = "/CostAnomaly/CustomThreshold"
  value  = var.custom_threshold_value
  tags   = merge(module.tags.tags, local.optional_tags)
}