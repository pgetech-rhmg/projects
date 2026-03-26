/*
* # AWS ASG with launch template module
* Terraform module which creates SAF2.0 ASG launch template in AWS.
*/
#
#  Filename    : aws/modules/asg/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : ASG with launch template terraform module creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    random = "~> 3.0"
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : asg with launch template module
# Description : This terraform module creates an ASG with launch template.

locals {
  namespace = "ccoe-tf-developers"

  launch_template         = var.create_launch_template ? aws_launch_template.launch_template[0].name : var.launch_template
  launch_template_version = var.create_launch_template && var.launch_template_version == "$Latest" ? aws_launch_template.launch_template[0].latest_version : var.launch_template_version



  enable_monitoring = true
  name              = var.instance_name
  asg_tags          = merge(var.tags, { pge_team = local.namespace, Name = local.name })
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

  dynamic "launch_template" {
    for_each = var.use_mixed_instances_policy ? [] : [1]

    content {
      name    = local.launch_template
      version = var.launch_template_version

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

  dynamic "tag" {
    for_each = local.module_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

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


resource "aws_launch_template" "launch_template" {
  count = var.create_launch_template ? 1 : 0

  name                   = var.launch_template_name
  update_default_version = var.update_default_version

  iam_instance_profile {
    name = var.iam_instance_profile
  }


  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) == null ? [] : ["ebs"]
        content {
          delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", null)
          encrypted             = true
          iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
          kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
          snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
          volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", null)
          throughput            = lookup(block_device_mappings.value.ebs, "throughput", null)
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = length(var.credit_specification) > 0 ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized



  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  kernel_id                            = var.kernel_id
  user_data                            = var.user_data
  ram_disk_id                          = var.ram_disk_id

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  monitoring {
    enabled = local.enable_monitoring
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = try(network_interfaces.value.associate_carrier_ip_address, null)
      delete_on_termination        = try(network_interfaces.value.delete_on_termination, null)
      description                  = try(network_interfaces.value.description, null)
      device_index                 = try(network_interfaces.value.device_index, null)
      interface_type               = try(network_interfaces.value.interface_type, null)
      ipv4_prefix_count            = try(network_interfaces.value.ipv4_prefix_count, null)
      ipv4_prefixes                = try(network_interfaces.value.ipv4_prefixes, null)
      ipv4_addresses               = try(network_interfaces.value.ipv4_addresses, [])
      ipv4_address_count           = try(network_interfaces.value.ipv4_address_count, null)
      network_interface_id         = try(network_interfaces.value.network_interface_id, null)
      network_card_index           = try(network_interfaces.value.network_card_index, null)
      private_ip_address           = try(network_interfaces.value.private_ip_address, null)
      security_groups              = compact(concat(try(network_interfaces.value.security_groups, []), var.security_groups))
      subnet_id                    = try(network_interfaces.value.subnet_id, null)
    }
  }

  dynamic "instance_market_options" {
    for_each = length(var.instance_market_options) > 0 ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = try([instance_market_options.value.spot_options], [])
        content {
          block_duration_minutes         = try(spot_options.value.block_duration_minutes, null)
          instance_interruption_behavior = try(spot_options.value.instance_interruption_behavior, null)
          max_price                      = try(spot_options.value.max_price, null)
          spot_instance_type             = try(spot_options.value.spot_instance_type, null)
          valid_until                    = try(spot_options.value.valid_until, null)
        }
      }
    }
  }

  dynamic "placement" {
    for_each = length(var.placement) > 0 ? [var.placement] : []
    content {
      affinity                = try(placement.value.affinity, null)
      availability_zone       = try(placement.value.availability_zone, null)
      group_name              = try(placement.value.group_name, null)
      host_id                 = try(placement.value.host_id, null)
      host_resource_group_arn = try(placement.value.host_resource_group_arn, null)
      spread_domain           = try(placement.value.spread_domain, null)
      tenancy                 = try(placement.value.tenancy, null)
      partition_number        = try(placement.value.partition_number, null)
    }
  }

  vpc_security_group_ids = length(var.network_interfaces) > 0 ? [] : var.security_groups

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = merge(var.tags, tag_specifications.value.tags)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.module_tags


}



