/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Maintenance-Window Automation Task resource in AWS
*/

# Filename    : modules/maintenance-window-tasks-automation/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : Provides an SSM Maintenance-Window Automation Task resource
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
    dynamic "automation_parameters" {
      for_each = toset(var.task_invocation_automation_parameters)
      content {
        document_version = automation_parameters.value.document_version

        dynamic "parameter" {
          for_each = toset(automation_parameters.value.auto_parameters)
          content {
            name   = parameter.value.name
            values = parameter.value.values
          }
        }

      }
    }
  }
}

