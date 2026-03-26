/*
* # AWS ASG with launch configuration module (Obselete)
* Terraform module which creates SAF2.0 ASG launch configuration in AWS.
* Terraform team doesn't support this module anymore. 
* The use of launch configurations is discouraged in favour of launch templates. Read more in the AWS EC2 Documentation.https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-configurations.html
*/
#
#  Filename    : aws/modules/asg/modules/asg_with_launch_configuration/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : ASG with launch configuration terraform module creation
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

# Module      : asg with launch configuration module
# Description : This terraform module creates an ASG with launch configuration.

locals {
  namespace         = "ccoe-tf-developers"
  metadata_options  = var.http_endpoint != null && var.http_tokens != null && var.http_put_response_hop_limit != null
  root_block_device = var.volume_type != null || var.volume_size != null || var.iops != null || var.throughput != null || var.delete_on_termination != null
  asg_tags          = merge(var.tags, { pge_team = local.namespace })
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
  name               = var.asg_name
  name_prefix        = var.asg_name_prefix
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

  launch_configuration      = aws_launch_configuration.launch_configuration.name
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

  dynamic "warm_pool" {
    for_each = var.warm_pool
    content {
      pool_state                  = lookup(warm_pool.value, "pool_state", null)
      min_size                    = lookup(warm_pool.value, "pool_min_size", null)
      max_group_prepared_capacity = lookup(warm_pool.value, "max_group_prepared_capacity", null)
    }
  }


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

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_launch_configuration" "launch_configuration" {
  name                 = var.use_config_name_prefix ? null : var.config_name
  name_prefix          = var.use_config_name_prefix ? var.config_name : null
  image_id             = var.image_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  dynamic "metadata_options" {
    for_each = local.metadata_options ? [true] : []
    content {
      http_endpoint               = var.http_endpoint
      http_tokens                 = var.http_tokens
      http_put_response_hop_limit = var.http_put_response_hop_limit
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = var.security_groups
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  enable_monitoring           = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized
  dynamic "root_block_device" {
    for_each = local.root_block_device ? [true] : []
    content {
      volume_type           = var.volume_type
      volume_size           = var.volume_size
      iops                  = var.iops
      throughput            = var.throughput
      delete_on_termination = var.delete_on_termination
      encrypted             = true
    }
  }
  dynamic "ebs_block_device" {
    for_each = var.device_name != null ? [true] : []
    content {
      device_name           = var.device_name
      snapshot_id           = var.snapshot_id
      volume_type           = var.ebs_volume_type
      volume_size           = var.ebs_volume_size
      iops                  = var.ebs_iops
      throughput            = var.ebs_throughput
      delete_on_termination = var.ebs_delete_on_termination
      encrypted             = true
      no_device             = var.no_device
    }
  }
  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_device_name != null || var.ephemeral_virtual_name != null ? [true] : []
    content {
      device_name  = var.ephemeral_device_name
      virtual_name = var.ephemeral_virtual_name
    }
  }
  spot_price        = var.spot_price
  placement_tenancy = var.placement_tenancy
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
