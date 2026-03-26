/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_service/main.tf
#  Date        : 31 December  2022
#  Author      : Tek Yantra
#  Description : ECS  service cloudwatch dashbaord creation
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


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name

  dashboard_body = <<EOT
{
    "widgets": [
        %{for idx, service in var.services}
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "${service.service_name}", "ClusterName", "${service.cluster_name}", { "id": "m1" } ],
                    [ { "expression": "ANOMALY_DETECTION_BAND(m1, 2)", "label": "CPUUtilization (expected)", "id": "ad1", "color": "#95A5A6" } ]
                ],
                "region": "${var.aws_region}",
                "title": "${service.widget_prefix} CPU/Memory"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${service.lb_arn_suffix}", { "stat": "Minimum" } ],
                    [ "...", { "yAxis": "left", "stat": "Maximum" } ],
                    [ "..." ],
                    [ "...", { "stat": "p90" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "title": "${service.widget_prefix} Response Time",
                "period": 300,
                "stat": "p50"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${service.lb_arn_suffix}" ],
                    [ ".", "HTTPCode_Target_4XX_Count", ".", "." ],
                    [ ".", "HTTPCode_ELB_502_Count", ".", "." ],
                    [ ".", "HTTPCode_ELB_5XX_Count", ".", "." ]
                ],
                "region": "${var.aws_region}",
                "title": "${service.widget_prefix} Requests"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "metric",
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", "${service.lb_arn_suffix}" ]
                ],
                "region": "${var.aws_region}",
                "title": "${service.widget_prefix} Traffic"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryReserved", "ServiceName", "${service.service_name}", "ClusterName", "${service.cluster_name}", { "region": "${var.aws_region}", "stat": "Average", "visible": true } ],
                    [ ".", "MemoryUtilized", ".", ".", ".", ".", { "region": "${var.aws_region}" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Maximum",
                "title" : "${service.widget_prefix}  MemoryUtilized"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuReserved", "ServiceName", "${service.service_name}", "ClusterName", "${service.cluster_name}", { "region": "${var.aws_region}", "stat": "Average", "visible": false } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "region": "${var.aws_region}" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Maximum",
                "title" : "${service.widget_prefix}  CpuUtilized"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${service.service_name}", "ClusterName", "${service.cluster_name}", { "region": "${var.aws_region}" } ],
                    [ ".", "DeploymentCount", ".", ".", ".", ".", { "region": "${var.aws_region}" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "region": "${var.aws_region}" } ],
                    [ ".", "DesiredTaskCount", ".", ".", ".", ".", { "region": "${var.aws_region}" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Sum",
                "period": 60,
                "title": "${service.widget_prefix} Task counts"
            }
        }%{if idx != length(var.services) - 1},%{endif}
        %{endfor}
    ]
}
EOT
}