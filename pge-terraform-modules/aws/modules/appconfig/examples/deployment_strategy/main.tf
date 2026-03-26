/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/deployment_strategy/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig deployment strategy

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

module "deployment_strategy" {
  source = "../../modules/deployment_strategy"

  name        = var.name
  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)

  deployment_duration = var.deployment_duration
  bake_time           = var.bake_time
  growth_factor       = var.growth_factor
  growth_type         = var.growth_type
  replicate_to        = var.replicate_to
}