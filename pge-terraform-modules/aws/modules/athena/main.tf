/*
 * Athena Workgroup Module
 *
 * Description:
 *   Provisions an AWS Athena Workgroup with configurable
 *   result output location, optional KMS encryption,
 *   and CloudWatch metrics publishing.
 *
 * This module intentionally deploys only the base Athena
 * workgroup resource. Optional integrations such as
 * AWS Glue databases, tables, or federated connectors
 * are implemented as separate submodules for composability.
 *
 * Resources Created:
 *   - aws_athena_workgroup
 *
 * Module Path:
 *   aws/modules/athena
 *
 * Author:
 *   PG&E 
 */



terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_athena_workgroup" "this" {
  name = var.athena_workgroup_name

  state = "ENABLED"
  tags  = local.module_tags
  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled

    result_configuration {
      output_location = var.output_location

      dynamic "encryption_configuration" {
        for_each = var.kms_key_arn != null ? [1] : []
        content {
          encryption_option = "SSE_KMS"
          kms_key_arn       = var.kms_key_arn
        }
      }
    }
  }
}