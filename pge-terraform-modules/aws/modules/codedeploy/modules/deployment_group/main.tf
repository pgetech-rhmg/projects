/*
 * # AWS CodeDeploy Deployment Group module
 * Terraform module which creates SAF2.0 CodeDeploy Deployment Group in AWS
*/

#
#  Filename    : aws/modules/codedeploy/modules/deployment_group/main.tf
#  Date        : 11 July 2022
#  Author      : TCS
#  Description : CodeDeploy module creates the CodeDeploy Deployment Group
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
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



# Provides a CodeDeploy Deployment Group for a CodeDeploy Application.
resource "aws_codedeploy_deployment_group" "deployment_group" {

  app_name               = var.deployment_group_app_name
  deployment_group_name  = var.deployment_group_name
  deployment_config_name = var.deployment_config_name
  service_role_arn       = var.deployment_group_service_role_arn
  autoscaling_groups     = var.autoscaling_groups
  tags                   = local.module_tags

  # This dynamic block will check whether the variable alarm_configuration_alarms is [] (null) or not.
  # This block will only execute when there is any input for alarms.
  dynamic "alarm_configuration" {
    for_each = var.alarm_configuration_alarms != [] ? [true] : []

    content {
      alarms                    = var.alarm_configuration_alarms
      enabled                   = var.alarm_configuration_enabled
      ignore_poll_alarm_failure = var.alarm_configuration_ignore_poll_alarm_failure
    }
  }

  # You can configure a deployment group to automatically rollback when a deployment fails or when a monitoring threshold you specify is met.
  # This dynamic block will check whether the value for the variable auto_rollback_configuration_enabled is true or not.
  # This block will only execute if the auto_rollback_configuration_enabled = true.
  dynamic "auto_rollback_configuration" {
    for_each = var.auto_rollback_configuration_enabled == true ? [true] : []

    content {
      enabled = var.auto_rollback_configuration_enabled
      events  = var.auto_rollback_configuration_events
    }
  }

  # You can configure options for a blue/green deployment.
  # This condition will loop over the variable blue_green_deployment_config and fetch the argument values for this resource.
  dynamic "blue_green_deployment_config" {
    for_each = var.blue_green_deployment_config
    content {
      # You can configure how traffic is rerouted to instances in a replacement environment in a blue/green deployment.
      dynamic "deployment_ready_option" {
        for_each = lookup(blue_green_deployment_config.value, "deployment_ready_option", {})

        content {
          action_on_timeout    = lookup(deployment_ready_option.value, "action_on_timeout", null)
          wait_time_in_minutes = lookup(deployment_ready_option.value, "wait_time_in_minutes", null)
        }
      }

      # You can configure how instances in the original environment are terminated when a blue/green deployment is successful.
      dynamic "green_fleet_provisioning_option" {
        for_each = lookup(blue_green_deployment_config.value, "green_fleet_provisioning_option", {})

        content {
          action = lookup(green_fleet_provisioning_option.value, "action", null)
        }
      }

      # You can configure how instances in the original environment are terminated when a blue/green deployment is successful.
      dynamic "terminate_blue_instances_on_deployment_success" {
        for_each = lookup(blue_green_deployment_config.value, "terminate_blue_instances_on_deployment_success", {})

        content {
          action                           = lookup(terminate_blue_instances_on_deployment_success.value, "action", null)
          termination_wait_time_in_minutes = lookup(terminate_blue_instances_on_deployment_success.value, "termination_wait_time_in_minutes", null)
        }
      }
    }
  }

  # You can configure the type of deployment, either in-place or blue/green, you want to run and whether to route deployment traffic behind a load balancer.
  # This condition will loop over the variable deployment_style and fetch the argument values for this resource
  # WITHOUT_TRAFFIC_CONTROL and IN_PLACE are the default values for deployment_option and deployment_type
  dynamic "deployment_style" {
    for_each = var.deployment_style

    content {
      deployment_option = lookup(deployment_style.value, "deployment_option", "WITHOUT_TRAFFIC_CONTROL")
      deployment_type   = lookup(deployment_style.value, "deployment_type", "IN_PLACE")
    }
  }

  # Tag filters associated with the deployment group.
  # This condition will loop over the variable ec2_tag_filter and fetch the argument values for this resource
  dynamic "ec2_tag_filter" {
    for_each = var.ec2_tag_filter

    content {
      key   = lookup(ec2_tag_filter.value, "key", null)
      type  = lookup(ec2_tag_filter.value, "type", null)
      value = lookup(ec2_tag_filter.value, "value", null)
    }
  }

  # You can form a tag group by putting a set of tag filters into ec2_tag_set.
  # This condition will loop over the variable ec2_tag_set and fetch the argument values for this resource.
  dynamic "ec2_tag_set" {
    for_each = var.ec2_tag_set

    content {
      dynamic "ec2_tag_filter" {
        for_each = ec2_tag_set.value.ec2_tag_filter
        content {
          key   = lookup(ec2_tag_filter.value, "key", null)
          type  = lookup(ec2_tag_filter.value, "type", null)
          value = lookup(ec2_tag_filter.value, "value", null)
        }
      }
    }
  }

  # This condition will loop over the variable ecs_service and fetch the argument values for this resource.
  # Both arguments cluster_name and  service_name are required for this block.
  dynamic "ecs_service" {
    for_each = var.ecs_service

    content {
      cluster_name = ecs_service.value.cluster_name
      service_name = ecs_service.value.service_name
    }
  }

  # You can configure the Load Balancer to use in a deployment.
  # This condition will loop over the variable load_balancer_info and fetch the argument values for this resource.
  dynamic "load_balancer_info" {
    for_each = var.load_balancer_info

    content {
      # The Classic Elastic Load Balancer to use in a deployment.
      dynamic "elb_info" {
        for_each = lookup(load_balancer_info.value, "elb_info", {})

        content {
          name = elb_info.value.name
        }
      }

      # The (Application/Network Load Balancer) target group to use in a deployment.
      dynamic "target_group_info" {
        for_each = lookup(load_balancer_info.value, "target_group_info", {})

        content {
          name = target_group_info.value.name
        }
      }

      # The (Application/Network Load Balancer) target group pair to use in a deployment.
      dynamic "target_group_pair_info" {
        for_each = lookup(load_balancer_info.value, "target_group_pair_info", {})

        content {
          # Configuration block for the production traffic route
          dynamic "prod_traffic_route" {
            for_each = lookup(target_group_pair_info.value, "prod_traffic_route", {})

            content {
              listener_arns = prod_traffic_route.value.listener_arns
            }
          }

          # Configuration blocks for a target group within a target group pair
          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "target_group", {})

            content {
              name = target_group.value.name
            }
          }

          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "blue_target_group", {})

            content {
              name = target_group.value.name
            }
          }

          dynamic "target_group" {
            for_each = lookup(target_group_pair_info.value, "green_target_group", {})

            content {
              name = target_group.value.name
            }
          }

          # Configuration block for the test traffic route
          dynamic "test_traffic_route" {
            for_each = lookup(target_group_pair_info.value, "test_traffic_route", {})

            content {
              listener_arns = test_traffic_route.value.listener_arns
            }
          }
        }
      }
    }
  }

  # On premise tag filters associated with the group.
  # This condition will loop over the variable on_premises_instance_tag_filter and fetch the argument values for this resource.
  dynamic "on_premises_instance_tag_filter" {
    for_each = var.on_premises_instance_tag_filter
    content {
      key   = lookup(on_premises_instance_tag_filter.value, "key", null)
      type  = lookup(on_premises_instance_tag_filter.value, "type", null)
      value = lookup(on_premises_instance_tag_filter.value, "value", null)
    }
  }

  # Add triggers to a Deployment Group to receive notifications about events related to deployments or instances in the group.
  # This condition will loop over the variable trigger_configuration and fetch the argument values for this resource.
  # All the three arguments trigger_events,trigger_name and trigger_target_arn are required.
  dynamic "trigger_configuration" {
    for_each = var.trigger_configuration
    content {
      trigger_events     = trigger_configuration.value.trigger_events
      trigger_name       = trigger_configuration.value.trigger_name
      trigger_target_arn = trigger_configuration.value.trigger_target_arn
    }
  }
}
