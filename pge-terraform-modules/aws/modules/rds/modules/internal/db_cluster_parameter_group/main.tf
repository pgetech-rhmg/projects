/*
 * # RDS db_cluster_parameter_group module
 * Terraform module which creates SAF2.0 db_cluster_parameter_group module
*/
#
#  Filename    : modules/rds/modules/internal/db_cluster_parameter_group/main.tf
#  Date        : 5/9/2022
#  Author      : PGE
#  Description : AWS db_cluster_parameter_group main file.
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
  name      = lower(var.name)
  namespace = "ccoe-tf-developers"
}



#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { Name = local.name, pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create ? 1 : 0

  name_prefix = var.name
  family      = var.family
  description = coalesce(var.description, format("%s cluster parameter group", local.name))

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
    }
  }

  tags = local.module_tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
    ]

  }
}
