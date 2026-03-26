/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Maintenance-Window Run-Command Task resource in AWS
*/

# Filename    : modules/maintenance-window-tasks-run-command/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : Provides an SSM Maintenance Window Run-command Task resource
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

resource "aws_ssm_maintenance_window_task" "task_patches" {
  name             = var.maintenance_window_task_name
  description      = var.maintenance_window_task_description
  window_id        = var.maintenance_window_id
  task_type        = var.maintenance_window_task_type
  task_arn         = var.maintenance_window_task_arn
  priority         = var.maintenance_window_task_priority
  service_role_arn = var.maintenance_window_task_service_role_arn
  max_concurrency  = var.maintenance_window_task_max_concurrency
  max_errors       = var.maintenance_window_task_max_errors
  cutoff_behavior  = var.maintenance_window_task_cutoff_behavior

  dynamic "targets" {
    for_each = toset(var.maintenance_windows_targets)
    content {
      key    = targets.value.key
      values = targets.value.values
    }
  }

  task_invocation_parameters {

    dynamic "run_command_parameters" {
      for_each = toset(var.maintenance_windows_run_command)
      content {
        output_s3_bucket     = lookup(run_command_parameters.value, "output_s3_bucket")
        output_s3_key_prefix = lookup(run_command_parameters.value, "output_s3_key_prefix", "scan")
        service_role_arn     = lookup(run_command_parameters.value, "sns_notification_role_arn", null)
        timeout_seconds      = lookup(run_command_parameters.value, "timeout_seconds", "600")
        document_hash        = lookup(run_command_parameters.value, "document_hash", null)
        document_hash_type   = lookup(run_command_parameters.value, "document_hash_type", null)

        dynamic "cloudwatch_config" {
          for_each = run_command_parameters.value.task_cloudwatch_config
          content {
            cloudwatch_log_group_name = lookup(cloudwatch_config.value, "cloudwatch_log_group_name", null)
            cloudwatch_output_enabled = lookup(cloudwatch_config.value, "cloudwatch_output_enabled", false)
          }
        }

        dynamic "parameter" {
          for_each = toset(run_command_parameters.value.task_run_command_parameters)
          content {
            name   = parameter.value.name
            values = parameter.value.values
          }
        }

        dynamic "notification_config" {
          for_each = lookup(run_command_parameters.value, "task_run_command_notification", [])
          content {
            notification_arn    = lookup(notification_config.value, "notification_arn")
            notification_events = lookup(notification_config.value, "notification_events", ["All"])
            notification_type   = lookup(notification_config.value, "notification_type", "Command")
          }
        }
      }
    }
  }
}