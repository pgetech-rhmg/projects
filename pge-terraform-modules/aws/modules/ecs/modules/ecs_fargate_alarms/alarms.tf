/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_fargate_alarms/alarms.tf
#  Date        : 10 Jan 2022
#  Author      : Tekyantra
#  Description : ECS container definitions resource creation
#

# Module      : ecs_fargate_alarms module
# Description : This terraform module creates a ecs_fargate_alarms.

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_cloudwatch_metric_alarm" "CPUUtilization_alarm" {
  alarm_name                = "${var.cluster_name}-cpu-${var.service_name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  tags                      = merge(local.module_tags, { alarm_name : "${var.cluster_name}-ECS-Low_CPUResv" })
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = var.cpu_alert_threshold
  alarm_description         = "This metric monitors ECS CPU utilization for ${var.service_name}"
  alarm_actions             = var.alert_actions
  ok_actions                = var.alert_actions
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "MemoryUtilization_alarm" {
  alarm_name                = "${var.cluster_name}-memory-${var.service_name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  tags                      = merge(local.module_tags, { alarm_name : "${var.cluster_name}-memory-${var.service_name}" })
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = var.memory_alert_threshold
  alarm_description         = "This metric monitors ECS memory utilization for ${var.service_name}"
  alarm_actions             = var.alert_actions
  ok_actions                = var.alert_actions
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "HTTPCode_ELB_5XX_Count_alarm" {
  alarm_name          = "${var.cluster_name}-http5xx-${var.service_name}"
  comparison_operator = "GreaterThanThreshold"
  tags                = merge(local.module_tags, { alarm_name : "${var.cluster_name}-http5xx-${var.service_name}" })

  evaluation_periods        = "1"
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = var.HTTPCode_ELB_5XX_threshold
  alarm_description         = "HTTP 5XX alarm for over 25 counts within 5 minutes for ${var.service_name}"
  alarm_actions             = var.alert_actions
  ok_actions                = var.alert_actions
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  dimensions = {
    LoadBalancer = var.lb_arn_suffix
  }
}