/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Maintenance-Window resource in AWS
*/

# Filename    : modules/maintenance-window/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : Provides an SSM Maintenance Window resource that helps define a schedule.
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
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ssm_maintenance_window" "window" {
  enabled                    = var.maintenance_window_enabled
  name                       = var.maintenance_window_name
  description                = var.maintenance_window_description
  schedule                   = var.maintenance_window_schedule
  duration                   = var.maintenance_window_duration
  cutoff                     = var.maintenance_window_cutoff
  schedule_timezone          = var.maintenance_window_schedule_timezone
  start_date                 = var.maintenance_window_start_date
  end_date                   = var.maintenance_window_end_date
  allow_unassociated_targets = var.maintenance_window_allow_unassociated_targets

  tags = local.module_tags
}

resource "aws_ssm_maintenance_window_target" "target" {
  count = var.maintenance_windows_targets != null ? 1 : 0

  window_id         = aws_ssm_maintenance_window.window.id
  resource_type     = var.maintenance_window_target_resource_type
  name              = var.maintenance_window_target_name
  description       = var.maintenance_window_target_description
  owner_information = var.maintenance_window_target_owner_information

  dynamic "targets" {
    for_each = toset(var.maintenance_windows_targets)
    content {
      key    = targets.value.key
      values = targets.value.values
    }
  }
}

