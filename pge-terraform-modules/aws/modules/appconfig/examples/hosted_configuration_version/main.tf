/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/hosted_configuration_version/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig hosted configuration version

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
module "hosted_configuration_version" {
  source = "../../modules/hosted_configuration_version"

  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)

  content                  = var.content
  configuration_profile_id = var.configuration_profile_id
  application_id           = var.application_id
}