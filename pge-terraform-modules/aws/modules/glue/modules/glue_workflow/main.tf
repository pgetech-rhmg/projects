/*
 * # AWS Glue workflow module.
 * Terraform module which creates SAF2.0 Glue workflow in AWS.
*/
#  Filename    : aws/modules/glue/modules/glue_workflow/main.tf
#  Date        : 29 August 2022
#  Author      : TCS
#  Description : Glue workflow Creation
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

# Module      : Creation of Glue workflow
# Description : This terraform module creates a Glue workflow.

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



resource "aws_glue_workflow" "glue_workflow" {
  name = var.glue_workflow_name

  description            = coalesce(var.glue_workflow_description, format("%s - Managed by Terraform", var.glue_workflow_name))
  default_run_properties = var.glue_workflow_default_run_properties
  max_concurrent_runs    = var.glue_workflow_max_concurrent_runs
  tags                   = local.module_tags
}
