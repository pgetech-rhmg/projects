# epic-pipeline-module-aws-cloudwatch

## Overview

Provisions the broader AWS CloudWatch primitives that the per-alarm module does not cover: a log group with explicit retention, optional metric filters attached to that log group, and an optional dashboard. Use [`epic-pipeline-module-aws-cloudwatch-alarm`](../epic-pipeline-module-aws-cloudwatch-alarm/) for `aws_cloudwatch_metric_alarm`.

The log group name follows the EPIC convention `/pge-epic/<app_name>/<environment>/<log_group_name>` unless `custom_log_group_name` overrides it. Each section (log group, metric filters, dashboard) is independently optional — set the relevant input to `null` or `[]` to skip that piece.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_cloudwatch_log_group.this` | Log group with explicit retention and optional KMS encryption |
| `aws_cloudwatch_log_metric_filter.this` | Metric filters attached to the log group (one per entry in `metric_filters`) |
| `aws_cloudwatch_dashboard.this` | CloudWatch dashboard rendered from `dashboard_body` |

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used for naming CloudWatch resources |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`) |
| `tags` | `map(string)` | Common tags applied to the log group |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `log_group_name` | `string` | `null` | Final segment of the log group path. Combined into `/pge-epic/<app_name>/<environment>/<log_group_name>`. Set to `null` to skip log group creation |
| `custom_log_group_name` | `string` | `null` | Full log group path override. Takes precedence over the auto-derived name |
| `retention_in_days` | `number` | `90` | Log group retention. Must be a CloudWatch-accepted bucket (e.g., `7`, `14`, `30`, `60`, `90`, `120`, `180`, `365`, `731`, `1827`, `3653`) |
| `log_group_kms_key_id` | `string` | `null` | KMS Key ARN for log group encryption. Required when `tags.DataClassification` is `Confidential`, `Restricted`, or `Privileged` |
| `log_group_skip_destroy` | `bool` | `false` | If `true`, the log group is preserved on `terraform destroy` |
| `metric_filters` | `list(object)` | `[]` | Metric filters to attach to the log group. See shape below |
| `custom_dashboard_name` | `string` | `null` | Full dashboard name override. Takes precedence over the auto-derived name `pge-epic-<app_name>-<environment>` |
| `dashboard_body` | `string` | `null` | JSON-encoded dashboard body. When `null`, no dashboard is created |

`metric_filters` object shape:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | yes | Metric filter name |
| `pattern` | `string` | yes | Log filter pattern |
| `metric_name` | `string` | yes | Emitted metric name |
| `metric_namespace` | `string` | yes | Metric namespace (e.g., `NfrTool/prod`) |
| `metric_value` | `string` | yes | Metric value expression (e.g., `"1"`) |
| `default_value` | `string` | no | Default value when the pattern does not match |
| `unit` | `string` | no | Metric unit |

## Outputs

| Name | Description |
|------|-------------|
| `log_group_name` | Resolved log group name (or `null` if not managed) |
| `log_group_arn` | Log group ARN (or `null` if not managed) |
| `metric_filter_names` | Map of metric filter logical name to attached filter name |
| `dashboard_arn` | Dashboard ARN (or `null` if no dashboard is managed) |
| `dashboard_name` | Dashboard name (or `null` if no dashboard is managed) |

## Usage in a Terraform project

Used directly from an application's `.infra/` folder. The example below provisions a Lambda log group with audit-grade retention, a metric filter that counts `ERROR` log lines, and a dashboard.

```hcl
module "audit_log_group" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch.git?ref=main"

  app_name    = var.project_tag
  environment = var.environment
  tags        = module.tags.tags

  log_group_name       = "audit"
  retention_in_days    = 180
  log_group_kms_key_id = module.logs_kms.key_arn

  metric_filters = [
    {
      name             = "${var.project_tag}-error-count-${var.environment}"
      pattern          = "ERROR"
      metric_name      = "ErrorCount"
      metric_namespace = "${var.project_tag}/${var.environment}"
      metric_value     = "1"
      default_value    = "0"
    }
  ]

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [["${var.project_tag}/${var.environment}", "ErrorCount"]]
          region  = "us-west-2"
          title   = "Error count"
        }
      }
    ]
  })
}
```

The `.infra/` folder is detected by EPIC at runtime — the application's `.pipeline/epic.json` does not need to reference this module directly.

## Usage from another module

Compose this module inside a higher-level module — for example, a per-Lambda observability wrapper that creates a log group, an `Errors` metric filter, and emits the log group name back to the caller:

```hcl
module "lambda_logs" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags

  log_group_name    = var.function_name
  retention_in_days = var.retention_in_days

  metric_filters = [
    {
      name             = "${var.function_name}-errors-${var.environment}"
      pattern          = "?ERROR ?Exception"
      metric_name      = "${var.function_name}Errors"
      metric_namespace = "${var.app_name}/${var.environment}"
      metric_value     = "1"
      default_value    = "0"
    }
  ]
}

output "log_group_name" {
  value = module.lambda_logs.log_group_name
}

output "log_group_arn" {
  value = module.lambda_logs.log_group_arn
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS Provider | `~> 5.90` |

The AWS provider declares a `us_east_1` configuration alias. Callers must pass it through (e.g., `providers = { aws.us_east_1 = aws.us_east_1 }`) even when no `us-east-1` resources are created in this module.

## Notes

- Log group, metric filters, and dashboard are each independently optional. Leaving `log_group_name` and `custom_log_group_name` both `null` skips the log group entirely; metric filters require a managed log group.
- When `tags.DataClassification` is `Confidential`, `Restricted`, or `Privileged`, `log_group_kms_key_id` is mandatory and the module will fail the plan otherwise.
- `retention_in_days` is validated against the CloudWatch-accepted retention buckets — arbitrary values are rejected.
