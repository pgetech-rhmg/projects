/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_capacity_provider/main.tf
#  Date        : 11 April 2022
#  Author      : TCS
#  Description : ECS capcity provider resource creation
#

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : ecs module
# Description : This terraform module creates a ecs.

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.ecs_capacity_provider_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = var.autoscaling_group_arn
    managed_scaling {
      instance_warmup_period    = var.asg_instance_warmup_period
      status                    = var.asg_status
      target_capacity           = var.asg_target_capacity
      maximum_scaling_step_size = var.asg_maximum_scaling_step_size
      minimum_scaling_step_size = var.asg_minimum_scaling_step_size
    }
    managed_termination_protection = var.managed_termination_protection
  }
  tags = local.module_tags
}