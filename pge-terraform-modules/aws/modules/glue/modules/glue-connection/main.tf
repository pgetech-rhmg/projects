/*
 * # AWS Glue Connection module.
 * Terraform module which creates SAF2.0 Glue Connection in AWS.
*/

#
#  Filename    : aws/modules/glue/modules/glue-connection/main.tf
#  Date        : 05 August 2022
#  Author      : TCS
#  Description : Glue Connection Creation
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

# Module      : Creation of Glue Connection
# Description : This terraform module creates a Glue Connection.

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



resource "aws_glue_connection" "glue_connection" {

  name            = var.glue_connection_name
  connection_type = var.glue_connection_type

  # As per SAF, Ensure all JDBC connections have "JDBC_ENFORCE_SSL" is enabled.
  connection_properties = (var.glue_connection_type == "JDBC" ? merge(var.glue_connection_properties, { "JDBC_ENFORCE_SSL" = "true" }) : var.glue_connection_properties)
  description           = coalesce(var.glue_connection_description, var.glue_connection_name)

  match_criteria = var.glue_connection_match_criteria
  catalog_id     = var.glue_connection_catalog_id

  dynamic "physical_connection_requirements" {
    for_each = var.glue_connection_physical_connection_requirements
    content {
      availability_zone      = lookup(physical_connection_requirements.value, "availability_zone", null)
      security_group_id_list = lookup(physical_connection_requirements.value, "security_group_id_list", null)
      subnet_id              = lookup(physical_connection_requirements.value, "subnet_id", null)
    }
  }

  tags = local.module_tags
}