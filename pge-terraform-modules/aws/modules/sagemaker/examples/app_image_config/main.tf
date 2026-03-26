/*
 * # AWS Sagemaker app_image_config example
*/
#
#  Filename    : aws/modules/sagemaker/examples/app_image_config/main.tf
#  Date        : 30 Aug 2022
#  Author      : TCS
#  Description : The terraform module creates app_image_config

locals {
  name = "${var.name}-${random_string.name.result}"
}

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

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "app_image_config" {
  source = "../../modules/app_image_config"

  app_image_config_name = local.name
  kernel_gateway_image_config = {
    kernel_spec = {
      name = "kernel-${local.name}"
    }
    file_system_config = {
      default_gid = var.default_gid
      default_uid = var.default_uid
    }
  }
  tags = merge(module.tags.tags, var.optional_tags)
}