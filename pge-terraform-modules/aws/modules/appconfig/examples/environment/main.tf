/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/environment/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig environment

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

module "environment" {
  source = "../../modules/environment"

  name        = var.name
  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)

  application_id = var.application_id
  monitors       = var.monitors
}