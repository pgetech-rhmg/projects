/*
 * # AWS Sagemaker model_package_group example
 * # Terraform module example usage for Sagemaker model_package_group
*/
#
#  Filename    : aws/modules/sagemaker/examples/model_package_group/main.tf
#  Date        : 01 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates model_package_group

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

# This will pull the model_package_group module
# Command to check model_package_group in CLI is 'aws sagemaker list-model-package-groups'
module "model_package_group" {
  source = "../../modules/model_package_group"

  model_package_group_name = local.name
  tags                     = merge(module.tags.tags, var.optional_tags)
}