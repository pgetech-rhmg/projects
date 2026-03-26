/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/application/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig application 

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

# Application with environments and monitors
module "appconfig" {
  source = "../../modules/application"

  name        = var.name
  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)
}