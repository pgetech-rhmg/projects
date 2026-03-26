/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_fargate_appautoscaling/main.tf
#  Date        : 16 August 2024
#  Author      : TCS
#  Description : ECS  FARGATE ecs_fargate_appautoscaling module creation
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
# Description : This terraform module creates a ecs with fargate.

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}


# Autoscalling fargate 


resource "aws_appautoscaling_target" "target" {
  count              = var.create_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = var.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = local.module_tags
}

resource "aws_appautoscaling_policy" "step_scaling" {
  count              = var.create_autoscaling && !var.use_target_tracking_scaling ? 1 : 0
  name               = var.step_scaling_policy_name
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.target[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.step_scaling_policy_configuration.adjustment_type
    cooldown                = var.step_scaling_policy_configuration.cooldown
    metric_aggregation_type = var.step_scaling_policy_configuration.metric_aggregation_type
    step_adjustment {
      metric_interval_lower_bound = var.step_scaling_policy_configuration.step_adjustment[0].metric_interval_lower_bound
      metric_interval_upper_bound = var.step_scaling_policy_configuration.step_adjustment[0].metric_interval_upper_bound
      scaling_adjustment          = var.step_scaling_policy_configuration.step_adjustment[0].scaling_adjustment
    }
  }
}



resource "aws_appautoscaling_policy" "target_tracking_scaling" {
  count              = var.create_autoscaling && var.use_target_tracking_scaling ? 1 : 0
  name               = var.target_tracking_scaling_policy_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.target[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.target_tracking_scaling_policy_configuration.target_value
    scale_in_cooldown  = var.target_tracking_scaling_policy_configuration.scale_in_cooldown
    scale_out_cooldown = var.target_tracking_scaling_policy_configuration.scale_out_cooldown
    disable_scale_in   = var.target_tracking_scaling_policy_configuration.disable_scale_in
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking_scaling_policy_configuration.predefined_metric_specification[0].predefined_metric_type
    }
  }
}