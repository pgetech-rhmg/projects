/*
* # AWS GLUE Workflow with usage example
* Terraform module which creates SAF2.0 Glue workflow in AWS.
*/
#
# Filename    : modules/glue/examples/glue_workflow/main.tf
# Date        : 31 August 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue workflow.

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

module "glue_workflow" {
  source = "../../../glue/modules/glue_workflow"

  glue_workflow_name = local.name

  glue_workflow_default_run_properties = var.glue_workflow_default_run_properties
  glue_workflow_max_concurrent_runs    = var.glue_workflow_max_concurrent_runs
  tags                                 = merge(module.tags.tags, local.optional_tags)
}