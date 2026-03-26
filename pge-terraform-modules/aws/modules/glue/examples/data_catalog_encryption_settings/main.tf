/*
* # AWS GLUE with usage example
* Terraform module which creates SAF2.0 Glue data catalog encryption settings resources in AWS.
* This module to be executed first to enable glue catalog encyption.
* When the encryption is turned on , all the future data catalog objects are encrypted.
* The encryption settings are applied for the entire data catalog which includes: 
* Databases, Tables, Partitions,Table Versions, Connections, User-defined Functions. 
*/
#
# Filename    : modules/glue/examples/data_catalog_encryption_settings/main.tf
# Date        : 25 August 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue data catalog encryption settings.

locals {
  name          = "${var.name}-${random_string.name.result}"
  Order         = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
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
  Order              = local.Order
}

module "glue_data_catalog_encryption_settings" {
  source = "../../../glue/modules/data-catalog-encryption-settings"

  connection_password_aws_kms_key_id    = module.kms_key.key_arn
  encryption_at_rest_sse_aws_kms_key_id = module.kms_key.key_arn
}

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.1"

  name     = local.name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, var.optional_tags)
}