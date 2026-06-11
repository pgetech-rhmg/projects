# epic-pipeline-module-aws-cloudwatch-alarm

## Overview

Provisions a single AWS CloudWatch metric alarm. Each invocation creates one alarm against a named metric in a given namespace, with configurable threshold, statistic, evaluation behavior, and notification actions.

This module is intended to be composed — instantiate one `module` block per alarm (API 5XX, Lambda errors, queue depth, etc.) and wire the `alarm_actions` list to an SNS topic ARN.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_cloudwatch_metric_alarm.this` | The CloudWatch metric alarm |

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `alarm_name` | `string` | CloudWatch alarm name |
| `namespace` | `string` | CloudWatch metric namespace (e.g., `AWS/ApiGateway`, `AWS/Lambda`) |
| `metric_name` | `string` | Metric name (e.g., `5XXError`, `Errors`, `Throttles`) |
| `threshold` | `number` | Threshold value the metric is compared against |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `alarm_description` | `string` | `""` | Human-readable description of the alarm |
| `statistic` | `string` | `"Average"` | Statistic to apply (`Average`, `Sum`, `Minimum`, `Maximum`, `SampleCount`) |
| `comparison_operator` | `string` | `"GreaterThanThreshold"` | Comparison operator |
| `period` | `number` | `300` | Evaluation period in seconds |
| `evaluation_periods` | `number` | `1` | Number of periods to evaluate |
| `dimensions` | `map(string)` | `{}` | Metric dimensions |
| `alarm_actions` | `list(string)` | `[]` | List of ARNs to notify on `ALARM` state (typically an SNS topic) |
| `ok_actions` | `list(string)` | `[]` | List of ARNs to notify on `OK` state |
| `treat_missing_data` | `string` | `"missing"` | How to treat missing data (`missing`, `ignore`, `breaching`, `notBreaching`) |
| `tags` | `map(string)` | `{}` | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| `alarm_arn` | CloudWatch alarm ARN |
| `alarm_name` | CloudWatch alarm name |

## Usage in a Terraform project

Used directly from an application's `.infra/` folder (typically `cloudwatch.tf`). The example below wires three alarms — API Gateway 5XX, Lambda errors, and DynamoDB throttles — to a shared SNS topic.

```hcl
module "alarm_api_5xx" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch-alarm.git?ref=main"

  alarm_name          = "${var.project_tag}-Api-5XXError-${var.environment}"
  alarm_description   = "API Gateway 5XX error rate exceeds threshold"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 5
  period              = 300
  evaluation_periods  = 1
  dimensions          = { ApiName = "${var.project_tag}-Api-${var.environment}" }
  alarm_actions       = [module.sns_observability_alerts.topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = module.tags.tags
}

module "alarm_lambda_errors" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch-alarm.git?ref=main"

  alarm_name          = "${var.project_tag}-Lambda-Errors-${var.environment}"
  alarm_description   = "Lambda invocation errors exceed threshold"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  threshold           = 10
  period              = 300
  evaluation_periods  = 1
  alarm_actions       = [module.sns_observability_alerts.topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = module.tags.tags
}

module "alarm_dynamodb_throttles" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch-alarm.git?ref=main"

  alarm_name         = "${var.project_tag}-DynamoDB-Throttles-${var.environment}"
  alarm_description  = "DynamoDB read/write throttle events"
  namespace          = "AWS/DynamoDB"
  metric_name        = "ThrottledRequests"
  statistic          = "Sum"
  threshold          = 1
  period             = 300
  evaluation_periods = 1
  alarm_actions      = [module.sns_observability_alerts.topic_arn]
  treat_missing_data = "notBreaching"
  tags               = module.tags.tags
}
```

The `.infra/` folder is detected by EPIC at runtime — the application's `.pipeline/epic.json` does not need to reference this module directly.

## Usage from another module

Compose this module inside a higher-level module (for example, an app-alerts wrapper that emits a fixed set of alarms per workload):

```hcl
module "alarm_cpu_high" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch-alarm.git?ref=main"

  alarm_name          = "${var.workload}-CPU-High-${var.environment}"
  alarm_description   = "CPU utilization above ${var.cpu_threshold}%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  period              = 60
  evaluation_periods  = 5
  dimensions          = { InstanceId = var.instance_id }
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}

output "cpu_alarm_arn" {
  value = module.alarm_cpu_high.alarm_arn
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS Provider | `~> 5.90` |
