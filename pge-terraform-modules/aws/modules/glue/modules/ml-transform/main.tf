/*
 * # AWS Glue ML Transform module.
 * Terraform module which creates SAF2.0 aws_glue_ml_transform in AWS.
*/
#
#  Filename    : aws/modules/glue/modules/ml-transform/main.tf
#  Date        : 29 August 2022
#  Author      : TCS
#  Description : Glue ML Transform Creation
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



resource "aws_glue_ml_transform" "glue_ml_transform" {
  name = var.ml_transform_name

  input_record_tables {
    database_name   = var.glue_database_name
    table_name      = var.table_name
    catalog_id      = var.catalog_id
    connection_name = var.connection_name
  }

  parameters {
    transform_type = var.transform_type

    find_matches_parameters {
      accuracy_cost_trade_off    = var.accuracy_cost_trade_off
      enforce_provided_labels    = var.enforce_provided_labels
      precision_recall_trade_off = var.precision_recall_trade_off
      primary_key_column_name    = var.primary_key_column_name
    }
  }

  role_arn          = var.role_arn
  description       = coalesce(var.description, format("%s - Managed by Terraform", var.ml_transform_name))
  glue_version      = var.glue_version
  max_capacity      = var.ml_transform.max_capacity
  max_retries       = var.max_retries
  timeout           = var.timeout
  worker_type       = var.ml_transform.worker_type
  number_of_workers = var.ml_transform.number_of_workers
  tags              = local.module_tags
}