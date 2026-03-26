/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM State manager Association resource in AWS
*/

# Filename    : modules/maintenance-window-tasks-automation/main.tf
# Date        : 01 August 2023
# Author      : PGE
# Description : Provides an State manager Association resource
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


data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# SSM Associations
# ------------------------------------------------------------------------------

resource "aws_ssm_association" "AutomationDocument" {
  name = var.ssm_document_name

  association_name                 = var.name
  schedule_expression              = var.schedule_expression
  compliance_severity              = var.approved_patches_compliance_level
  automation_target_parameter_name = var.automation_target_parameter_name != null ? var.automation_target_parameter_name : null
  parameters                       = var.document_parameters != null ? var.document_parameters : null
  max_concurrency                  = var.max_concurrency != null ? var.max_concurrency : null
  apply_only_at_cron_interval      = var.apply_only_at_cron_interval


  dynamic "targets" {
    for_each = var.association_targets
    content {
      key    = lookup(targets.value, "key")
      values = lookup(targets.value, "values")
    }
  }

  output_location {
    s3_bucket_name = var.s3_bucket_name
    s3_key_prefix  = var.s3_key_prefix
  }
}

