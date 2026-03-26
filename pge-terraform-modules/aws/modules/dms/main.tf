/*
 * # AWS DMS Replication Task module.
 * Terraform module which creates SAF2.0 DMS Replication Task in AWS.
*/

#
#  Filename    : aws/modules/dms/modules/dms_replication_task/main.tf
#  Date        : 29 March 2022
#  Author      : TCS
#  Description : DMS Replication Task Creation
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

# Module      : DMS replication task Creation
# Description : This terraform module creates a DMS Replication Task.

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


resource "aws_dms_replication_task" "dms_replication_task" {

  migration_type           = var.migration_type
  replication_instance_arn = var.replication_instance_arn
  replication_task_id      = var.replication_task_id
  source_endpoint_arn      = var.source_endpoint_arn
  table_mappings           = var.table_mappings
  target_endpoint_arn      = var.target_endpoint_arn

  cdc_start_position        = var.cdc_start_position
  cdc_start_time            = var.cdc_start_time
  replication_task_settings = var.replication_task_settings
  start_replication_task    = var.start_replication_task
  tags                      = local.module_tags

}

