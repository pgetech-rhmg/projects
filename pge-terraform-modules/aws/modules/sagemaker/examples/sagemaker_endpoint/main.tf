/*
 * # AWS Sagemaker_endpoint
 * # Terraform module which creates Sagemaker endpoint
*/
#
#  Filename    : aws/modules/sagemaker/examples/sagemaker_endpoint/main.tf
#  Date        : August 30 2022
#  Author      : TCS
#  Description : The terraform module creates a sagemaker endpoint for Sagemaker

locals {
  optional_tags = var.optional_tags
  name          = "${var.name}-${random_string.name.result}"
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
  length           = 8
  special          = true
  override_special = "-"
}

module "endpoint" {
  source = "../../modules/sagemaker_endpoint"

  name                 = local.name
  endpoint_config_name = var.endpoint_config_name
  deployment_config    = var.deployment_config
  tags                 = merge(module.tags.tags, local.optional_tags)
}