/*
 * # AWS CodeDeploy Deployment Config module
 * Terraform module which creates SAF2.0 CodeDeploy Deployment Config in AWS
*/

#
#  Filename    : aws/modules/codedeploy/modules/codedeploy_deployment_config/main.tf
#  Date        : 5 July 2022
#  Author      : TCS
#  Description : CodeDeploy module creates the CodeDeploy Deployment Config
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

# Provides a CodeDeploy deployment config for an application
resource "aws_codedeploy_deployment_config" "deployment_config" {

  deployment_config_name = var.deployment_config_name
  compute_platform       = var.deployment_config_compute_platform

  # This dynamic block will be executed only if the variable minimum_healthy_hosts is not equal to null and
  # the variable deployment_config_compute_platform takes Server as the input value.
  # The arguments type and value is required.
  dynamic "minimum_healthy_hosts" {
    for_each = var.minimum_healthy_hosts != null && var.deployment_config_compute_platform == "Server" ? [var.minimum_healthy_hosts] : []
    content {
      type  = minimum_healthy_hosts.value.type
      value = minimum_healthy_hosts.value.value
    }
  }

  # This dynamic block will be executed only if the variable traffic_routing_config is not equal to null and
  # the variable deployment_config_compute_platform takes Lambda or ECS as the input value.
  # The arguments type, interval and percentage are required.
  dynamic "traffic_routing_config" {
    for_each = var.traffic_routing_config != null && var.deployment_config_compute_platform == "Lambda" || var.deployment_config_compute_platform == "ECS" ? [var.traffic_routing_config] : []

    content {
      type = traffic_routing_config.value.type

      # This dynamic block will be executed only if the variable traffic_routing_config is not equal to null and
      # the argument type is equal to TimeBasedLinear.
      dynamic "time_based_linear" {
        for_each = var.traffic_routing_config != null && lookup(var.traffic_routing_config, "type", null) == "TimeBasedLinear" ? [var.traffic_routing_config] : []

        content {
          interval   = traffic_routing_config.value.interval
          percentage = traffic_routing_config.value.percentage
        }
      }

      # This dynamic block will be executed only if the variable traffic_routing_config is not equal to null and
      # the argument type is equal to TimeBasedCanary.
      dynamic "time_based_canary" {
        for_each = var.traffic_routing_config != null && lookup(var.traffic_routing_config, "type", null) == "TimeBasedCanary" ? [var.traffic_routing_config] : []

        content {
          interval   = traffic_routing_config.value.interval
          percentage = traffic_routing_config.value.percentage
        }
      }
    }
  }
}