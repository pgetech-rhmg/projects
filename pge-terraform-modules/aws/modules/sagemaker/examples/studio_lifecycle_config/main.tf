/*
 * # AWS Sagemaker studio_lifecycle_config example
 * # Usage example of AWS Sagemaker studio_lifecycle_config
*/
#
#  Filename    : aws/modules/sagemaker/examples/studio_lifecycle_config/main.tf
#  Date        : 02 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates studio_lifecycle_config

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

module "studio_lifecycle_config" {
  source = "../../modules/studio_lifecycle_config"

  studio_lifecycle_config_name     = local.name
  studio_lifecycle_config_app_type = var.studio_lifecycle_config_app_type
  studio_lifecycle_config_content  = base64encode(file("${path.module}/${var.studio_lifecycle_config_content}"))
  tags                             = merge(module.tags.tags, var.optional_tags)
}