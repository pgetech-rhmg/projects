/*
* # AWS GLUE with usage example
* Terraform module which creates SAF2.0 Glue schema and Glue registry resources in AWS. 
*/
#
# Filename    : modules/glue/examples/glue_schema_registry/main.tf
# Date        : 24 August 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue schema registry.

locals {
  optional_tags = var.optional_tags
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

module "glue_registry" {
  source = "../../../glue/modules/glue-registry"

  glue_registry_name = local.name
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "glue_schema" {
  source = "../../../glue/modules/glue_schema"

  glue_schema_name       = var.glue_schema_name
  glue_registry_arn      = module.glue_registry.glue_registry_arn
  glue_data_format       = var.glue_data_format
  glue_compatibility     = var.glue_compatibility
  glue_schema_definition = var.glue_schema_definition
  tags                   = merge(module.tags.tags, local.optional_tags)
}