/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_ec2_alarms/main.tf
#  Date        : 6 February 2023
#  Author      : Tek Yantra
#  Description : ECS EC2 Alarms module creation
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

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Cloudwatch Alarm for ECS Cluster

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-CPUReservation" {
  alarm_name          = "${var.cluster_name}-ECS-High_CPUResv"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  tags                = merge(local.module_tags, { alarm_name : "${var.cluster_name}-ECS-High_CPUResv" })

  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "CPUReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = var.cluster_name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = [var.sns_topic_cloudwatch_alarm_arn]
  alarm_actions = [
  var.sns_topic_cloudwatch_alarm_arn]

}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-CPUReservation" {
  alarm_name          = "${var.cluster_name}-ECS-Low_CPUResv"
  comparison_operator = "LessThanThreshold"
  tags                = merge(local.module_tags, { alarm_name : "${var.cluster_name}-ECS-Low_CPUResv" })
  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "40"
  alarm_description = ""

  metric_name = "CPUReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = var.cluster_name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = [var.sns_topic_cloudwatch_alarm_arn]
  alarm_actions = [
    var.sns_topic_cloudwatch_alarm_arn,
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-MemReservation" {
  alarm_name          = "${var.cluster_name}-ECS-High_MemResv"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  tags                = merge(local.module_tags, { alarm_name : "${var.cluster_name}-ECS-High_MemResv" })
  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = var.cluster_name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = [var.sns_topic_cloudwatch_alarm_arn]
  alarm_actions = [
    var.sns_topic_cloudwatch_alarm_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-MemReservation" {
  alarm_name          = "${var.cluster_name}-ECS-Low_MemResv"
  comparison_operator = "LessThanThreshold"
  tags                = merge(local.module_tags, { alarm_name : "${var.cluster_name}-ECS-Low_MemResv" })
  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "40"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = var.cluster_name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = [var.sns_topic_cloudwatch_alarm_arn]
  alarm_actions = [
    var.sns_topic_cloudwatch_alarm_arn
  ]
}

# # Cloudwatch Alarm for ASG (of ECS Cluster)

resource "aws_cloudwatch_metric_alarm" "ecs-asg-alert_Has-SystemCheckFailure" {
  alarm_name          = "${var.cluster_name}-ECS-Has_SysCheckFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  tags                = local.module_tags
  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Sum"
  threshold         = "1"
  alarm_description = ""

  metric_name = "StatusCheckFailed"
  namespace   = "AWS/EC2"
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = [var.sns_topic_cloudwatch_alarm_arn]
  alarm_actions = [
    var.sns_topic_cloudwatch_alarm_arn,
  ]
}