/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Maintenance-Window Step-Function Task resource in AWS
*/

# Filename    : modules/maintenance-window-tasks-step-function/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : Provides an SSM Maintenance Window Step-Function Task resource
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
    dynamic "step_functions_parameters" {
      for_each = toset(var.task_invocation_step_functions_parameters)
      content {
        input = step_functions_parameters.value.input
        name  = step_functions_parameters.value.name
      }
    }
  }
}

