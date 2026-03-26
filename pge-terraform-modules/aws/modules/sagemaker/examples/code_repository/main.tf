/*
 * # AWS Sagemaker
*/
#
#  Filename    : aws/modules/sagemaker/examples/code_repository/main.tf
#  Date        : 25 Aug 2022
#  Author      : TCS
#  Description : The terraform module creates code_repository

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
  length  = 8
  upper   = false
  special = false
}

# This will pull the code_repository module
module "code_repository" {
  source = "../../modules/code_repository"

  code_repository_name = local.name
  repository_url       = var.repository_url
  tags                 = merge(module.tags.tags, local.optional_tags)
}