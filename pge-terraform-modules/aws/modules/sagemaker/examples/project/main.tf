/*
 * # AWS Sagemaker Project example
 * # Terraform module example usage for Sagemaker Project
*/
#
#  Filename    : aws/modules/sagemaker/examples/project/main.tf
#  Date        : 06 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates Sagemaker Project

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

# This will pull the project module
module "project" {
  source = "../../modules/project"

  project_name = local.name
  service_catalog_provisioning_details = [{
    product_id               = var.product_id
    provisioning_artifact_id = var.provisioning_artifact_id
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}