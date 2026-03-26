/*
 * # AWS Glue schema module.
 * Terraform module which creates SAF2.0 Glue Schema in AWS.
*/
#
#  Filename    : aws/modules/glue/modules/glue_schema/main.tf
#  Date        : 24 Auguest 2022
#  Author      : TCS
#  Description : Glue schema Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Glue schema
# Description : This terraform module creates a Glue schema.

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_glue_schema" "glue_schema" {

  schema_name       = var.glue_schema_name
  registry_arn      = var.glue_registry_arn
  data_format       = var.glue_data_format
  compatibility     = var.glue_compatibility
  schema_definition = var.glue_schema_definition

  description = coalesce(var.glue_schema_description, format("%s - Managed by Terraform", var.glue_schema_name))
  tags        = local.module_tags
}