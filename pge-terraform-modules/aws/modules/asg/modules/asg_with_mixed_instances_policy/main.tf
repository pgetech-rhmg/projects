#
#  Filename    : aws/modules/asg/modules/asg_with_mixed_instances_policy/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : ASG with mixed instances policy terraform module creation
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

# Module      : asg with mixed instances policy module
# Description : This terraform module creates an ASG with mixed instances policy.

locals {
  namespace = "ccoe-tf-developers"
  asg_tags  = merge(var.tags, { pge_team = local.namespace })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(local.asg_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


resource "aws_autoscaling_group" "asg" {
  name        = var.asg_name
  name_prefix = var.asg_name_prefix

  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  availability_zones = var.asg_availability_zones
  capacity_rebalance = var.asg_capacity_rebalance
  default_cooldown   = var.asg_default_cooldown
  dynamic "tag" {
    for_each = local.module_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  mixed_instances_policy {
    dynamic "instances_distribution" {
      for_each = var.on_demand_allocation_strategy != null || var.on_demand_base_capacity != null || var.on_demand_percentage_above_base_capacity != null || var.spot_allocation_strategy != null || var.spot_instance_pools != null || var.spot_max_price != null ? [true] : []
      content {
        on_demand_allocation_strategy            = var.on_demand_allocation_strategy
        on_demand_base_capacity                  = var.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
        spot_allocation_strategy                 = var.spot_allocation_strategy
        spot_instance_pools                      = var.spot_instance_pools
        spot_max_price                           = var.spot_max_price
      }
    }
    launch_template {
      launch_template_specification {
        launch_template_id   = var.launch_template_specification_id
        launch_template_name = var.launch_template_specification_name
        version              = var.launch_template_specification_version
      }
      dynamic "override" {
        for_each = var.instance_type != null || var.weighted_capacity != null ? [true] : []
        content {
          instance_type     = var.instance_type
          weighted_capacity = var.weighted_capacity
          launch_template_specification {
            launch_template_id   = var.launch_template_specification_id
            launch_template_name = var.launch_template_specification_name
            version              = var.launch_template_specification_version
          }
        }
      }
    }
  }
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  desired_capacity          = var.asg_desired_capacity
  force_delete              = var.asg_force_delete
  load_balancers            = var.asg_load_balancers
  vpc_zone_identifier       = var.asg_vpc_zone_identifier
  target_group_arns         = var.asg_target_group_arns
  termination_policies      = [var.asg_termination_policies]
  suspended_processes       = var.asg_suspended_processes
  placement_group           = var.asg_placement_group
  metrics_granularity       = "1Minute"
  enabled_metrics           = var.asg_enabled_metrics
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout
  min_elb_capacity          = var.asg_min_elb_capacity
  wait_for_elb_capacity     = var.asg_wait_for_elb_capacity
  protect_from_scale_in     = var.asg_protect_from_scale_in
  service_linked_role_arn   = var.asg_service_linked_role_arn
  max_instance_lifetime     = var.asg_max_instance_lifetime


  dynamic "initial_lifecycle_hook" {
    for_each = var.initial_lifecycle_hooks
    content {
      name                    = initial_lifecycle_hook.value.name
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
    }
  }

  dynamic "instance_refresh" {
    for_each = var.strategy == "Rolling" ? [true] : []
    content {
      strategy = var.strategy
      triggers = var.triggers
      preferences {
        checkpoint_delay       = var.checkpoint_delay
        checkpoint_percentages = var.checkpoint_percentages
        instance_warmup        = var.instance_warmup
        min_healthy_percentage = var.min_healthy_percentage
      }
    }
  }
}

resource "aws_autoscaling_policy" "autoscaling_policy" {
  name                      = var.autoscaling_policy_name
  policy_type               = var.policy_type
  scaling_adjustment        = var.scaling_adjustment
  adjustment_type           = var.adjustment_type
  cooldown                  = var.cooldown
  estimated_instance_warmup = var.estimated_instance_warmup
  autoscaling_group_name    = aws_autoscaling_group.asg.name
}
