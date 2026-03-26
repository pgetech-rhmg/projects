/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_service/main.tf
#  Date        : 13 April 2022
#  Author      : TCS
#  Description : ECS  service resource creation
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

resource "aws_ecs_service" "ecs_service" {
  name = var.service_name

  # The condition will execute this block only when the variable capacity_provider_strategy has value.
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy != null ? [true] : []
    content {
      base              = lookup(capacity_provider_strategy.value, "base", null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  # The condition will execute this block only when the variable deployment_circuit_breaker has value.
  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [true] : []
    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  deployment_controller {
    type = var.deployment_type
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = var.iam_role
  availability_zone_rebalancing      = var.availability_zone_rebalancing

  # The condition will execute this block if the value of the variable deployment_type is not "EXTERNAL".
  dynamic "load_balancer" {
    for_each = var.deployment_type != "EXTERNAL" ? var.load_balancer : []
    content {
      elb_name         = lookup(load_balancer.value, "elb_name", null)
      target_group_arn = var.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # The condition will execute this block if the value of the variable deployment_type is not "EXTERNAL".
  dynamic "network_configuration" {
    for_each = var.deployment_type != "EXTERNAL" ? [true] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = false
    }
  }

  cluster = var.ecs_service_cluster_id
  # The variable task_definition will take value if the value of the variable deployment_type is not "EXTERNAL".
  task_definition = var.deployment_type == "EXTERNAL" ? null : var.ecs_service_task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.ecs_service_launch_type

  # The condition will execute this block only when the variable ordered_placement_strategy has value.
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy != null ? [true] : []
    content {
      type  = ordered_placement_strategy.value.type
      field = lookup(ordered_placement_strategy.value, "field", null)
    }
  }

  # The condition will execute this block only when the variable placement_constraints has value.
  dynamic "placement_constraints" {
    for_each = var.ecs_service_placement_constraints != null ? [true] : []
    content {
      type       = placement_constraints.value.type
      expression = lookup(placement_constraints.value, "expression", null)
    }
  }

  # The variable platform_version will take the value if the value of the variable deployment_type is not "EXTERNAL".
  platform_version    = var.deployment_type == "EXTERNAL" ? null : var.service_platform_version
  propagate_tags      = var.propagate_tags
  scheduling_strategy = var.scheduling_strategy

  # The condition will execute this block only when the variable service_registries has value.
  dynamic "service_registries" {
    for_each = var.service_registries != null ? [true] : []
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = lookup(service_registries.value, "port", null)
      container_port = lookup(service_registries.value, "container_port", null)
      container_name = lookup(service_registries.value, "container_name", null)
    }
  }
  wait_for_steady_state = var.wait_for_steady_state
  tags                  = local.module_tags

  # Ignoring the load-balancer Target-group changes occurs outside of TF code in ECS Bluegreen/Canary deployment
  lifecycle {
    ignore_changes = [
      load_balancer, platform_version
    ]
  }
}