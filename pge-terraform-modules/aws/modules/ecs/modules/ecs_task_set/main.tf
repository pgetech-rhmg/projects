/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_task_set/main.tf
#  Date        : 13 April 2022
#  Author      : TCS
#  Description : ECS task set resource creation
# 
# Note : The resource "ecs_task_set" will only be created if the argument "deployment_type" is "EXTERNAL" 
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

resource "aws_ecs_task_set" "ecs_task_set" {
  service         = var.ecs_service_id
  cluster         = var.ecs_cluster_id
  task_definition = var.ecs_task_definition_arn

  # The condition will execute this block only when the variable capacity_provider_strategy has value.
  dynamic "capacity_provider_strategy" {
    for_each = var.ecs_task_set_capacity_provider_strategy != null ? [true] : []
    content {
      base              = lookup(ecs_task_set_capacity_provider_strategy.value, "base", null)
      capacity_provider = ecs_task_set_capacity_provider_strategy.value.capacity_provider
      weight            = ecs_task_set_capacity_provider_strategy.value.weight
    }
  }

  external_id  = var.external_id
  force_delete = var.force_delete
  launch_type  = var.ecs_task_launch_type

  # The condition will loop over the variable task_load_balancer and fetch the argument values for this resource
  dynamic "load_balancer" {
    for_each = var.task_load_balancer
    content {
      container_name     = load_balancer.value.container_name
      load_balancer_name = lookup(load_balancer.value, "load_balancer_name", null)
      target_group_arn   = var.task_target_group_arn
      container_port     = load_balancer.value.container_port
    }
  }

  # The variable task_set_platform_version will take value only when the value of the variable ecs_task_launch_type is FARGATE.
  platform_version = var.ecs_task_launch_type == "EC2" ? null : var.task_set_platform_version

  network_configuration {
    subnets          = var.task_subnets
    security_groups  = var.task_security_groups
    assign_public_ip = false
  }

  scale {
    unit  = var.task_set_scale_unit
    value = var.task_set_scale_value
  }

  # The condition will execute this block only when the variable task_service_registries has value.
  dynamic "service_registries" {
    for_each = var.task_service_registries != null ? [true] : []
    content {
      registry_arn   = task_service_registries.value.registry_arn
      port           = lookup(task_service_registries.value, "port", null)
      container_port = lookup(task_service_registries.value, "container_port", null)
      container_name = lookup(task_service_registries.value, "container_name", null)
    }
  }

  tags                      = local.module_tags
  wait_until_stable         = var.wait_until_stable
  wait_until_stable_timeout = var.wait_until_stable_timeout
}