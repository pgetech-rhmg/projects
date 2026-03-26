/*
 * # AWS DataSync module
 * Terraform module which creates SAF2.0 DataSync resources in AWS
*/
#
# Filename    : modules/datasync/main.tf
# Date        : 07 May 2024
# Author      : Eric Barnard (e6bo@pge.com)
# Description : Creates a DataSync task in AWS
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
  namespace                = "ccoe-tf-developers"
  module_tags              = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn != null ? var.cloudwatch_log_group_arn : module.cloudwatch_log_group[0].cloudwatch_log_group_arn
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_datasync_task" "datasync" {
  name                     = var.task_name
  destination_location_arn = var.destination_location_arn
  source_location_arn      = var.source_location_arn
  cloudwatch_log_group_arn = local.cloudwatch_log_group_arn

  options {
    atime                          = var.atime
    bytes_per_second               = var.bytes_per_second
    gid                            = var.gid
    log_level                      = var.log_level
    mtime                          = var.mtime
    object_tags                    = var.object_tags
    overwrite_mode                 = var.overwrite_mode
    posix_permissions              = var.posix_permissions
    preserve_deleted_files         = var.preserve_deleted_files
    preserve_devices               = var.preserve_devices
    security_descriptor_copy_flags = var.security_descriptor_copy_flags
    task_queueing                  = var.task_queueing
    transfer_mode                  = var.transfer_mode
    uid                            = var.uid
    verify_mode                    = var.verify_mode
  }

  dynamic "schedule" {
    for_each = var.schedule_expression != null ? [1] : []
    content {
      schedule_expression = var.schedule_expression
    }
  }

  dynamic "excludes" {
    for_each = var.excludes
    content {
      filter_type = excludes.value.filter_type
      value       = excludes.value.value
    }
  }

  dynamic "includes" {
    for_each = var.includes
    content {
      filter_type = includes.value.filter_type
      value       = includes.value.value
    }
  }

  dynamic "task_report_config" {
    for_each = var.create_task_report ? [1] : []
    content {
      s3_destination {
        bucket_access_role_arn = var.task_report_bucket_access_role_arn
        s3_bucket_arn          = var.task_report_s3_bucket_arn
        subdirectory           = var.task_report_subdirectory
      }

      s3_object_versioning = var.task_report_s3_object_versioning
      output_type          = var.task_report_output_type

      dynamic "report_overrides" {
        for_each = var.task_report_overrides ? [1] : []
        content {
          deleted_override     = var.task_report_deleted_override
          skipped_override     = var.task_report_skipped_override
          transferred_override = var.task_report_transferred_override
          verified_override    = var.task_report_verified_override
        }
      }
    }
  }

  tags = local.module_tags
}

module "cloudwatch_log_group" {
  count = var.cloudwatch_log_group_arn == null ? 1 : 0

  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.0"

  name_prefix = var.cloudwatch_log_group_name_prefix
  kms_key_id  = var.kms_key_id
  tags        = local.module_tags
}