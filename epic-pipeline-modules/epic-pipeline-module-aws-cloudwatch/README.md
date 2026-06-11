# EPIC AWS CloudWatch Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-cloudwatch
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **broader AWS CloudWatch Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module covers the parts of CloudWatch the existing [epic-pipeline-module-aws-cloudwatch-alarm](../epic-pipeline-module-aws-cloudwatch-alarm/) does not: **log groups** with explicit retention, **metric filters** keyed off log group content, and **dashboards** for operational visibility. Use the existing alarm module for `aws_cloudwatch_metric_alarm`.

> Per PG&E SAF 2.0: every Lambda log group **must be an explicit resource** with `retention_in_days` set — the default `Never Expire` is rejected. Audit-relevant log groups (handler paths writing to `audit_log`, RDS cluster logs) use `180`; standard Lambdas use `90`.

---

## Design Principles

- Explicit log groups only (no auto-creation by Lambda)
- Retention set explicitly per group
- KMS CMK supported for `Confidential` data
- Naming convention enforced by default (`/pge-epic/<app>/<env>/<name>`)
- Compatible with EPIC auto-wiring and orchestration

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions and validations:

| SAF # | Control | Enforcement |
|---|---|---|
| #2 | PG&E-managed CMK | `log_group_kms_key_id` mandatory when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged` |
| #7 | Retention | `retention_in_days` validated against CloudWatch-accepted buckets; default `90` (SAF-accepted) |

Out of module scope: alarms (use `epic-pipeline-module-aws-cloudwatch-alarm`), CloudWatch / Logs / Events / Monitoring VPC endpoints, IAM `logs:PutLogEvents` grants on consumer roles.

---

## What This Module Is (and Is Not)

### This module IS
- A CloudWatch log group + metric filter + dashboard primitive
- A retention-enforcement surface

### This module is NOT
- A metric alarm module (use [epic-pipeline-module-aws-cloudwatch-alarm](../epic-pipeline-module-aws-cloudwatch-alarm/))
- A canary / synthetics module
- A contributor insights module
- A subscription filter module (compose externally if needed)

---

## Resources Created

- Optional: `aws_cloudwatch_log_group`
- Optional: `aws_cloudwatch_log_metric_filter` (one per `metric_filters` entry)
- Optional: `aws_cloudwatch_dashboard`

All three are independently optional — set the relevant inputs to provision only what you need.

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `log_group_name` | Log group suffix (creates a log group when set) | `null` |
| `custom_log_group_name` | Full log group path override | `null` |
| `retention_in_days` | Log retention bucket (must be CloudWatch-accepted) | `90` |
| `log_group_kms_key_id` | CMK for log group encryption | `null` |
| `log_group_skip_destroy` | Preserve log group on destroy | `false` |
| `metric_filters` | List of metric filter objects | `[]` |
| `custom_dashboard_name` | Full dashboard name override | `null` |
| `dashboard_body` | JSON-encoded dashboard body (creates a dashboard when set) | `null` |

---

## Outputs

| Name | Description |
|---|---|
| `log_group_name` | Resolved log group name |
| `log_group_arn` | Log group ARN |
| `metric_filter_names` | Map of metric filter name → attached name |
| `dashboard_name` | Dashboard name |
| `dashboard_arn` | Dashboard ARN |

---

## Example Usage (Direct Terraform)

Log group only:

```hcl
module "lambda_logs" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch.git"

  app_name       = "nfr-tool"
  environment    = "dev"
  log_group_name = "lambda/assessments"
  retention_in_days = 90

  tags = module.tags.tags
}
```

With a metric filter for error counts:

```hcl
module "agent_api_logs" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudwatch.git"

  app_name          = "nfr-tool"
  environment       = "dev"
  log_group_name    = "lambda/agent-api"
  retention_in_days = 180
  log_group_kms_key_id = module.kms.key_arn

  metric_filters = [{
    name             = "error-count"
    pattern          = "{ $.level = \"error\" }"
    metric_name      = "AgentApiErrorCount"
    metric_namespace = "NfrTool/dev"
    metric_value     = "1"
    default_value    = "0"
  }]

  tags = module.tags.tags
}
```

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: lambda-assessments-logs
    path: epic-pipeline-module-aws-cloudwatch
    variables:
      app_name: ${app_name}
      environment: ${environment}
      log_group_name: lambda/assessments
      retention_in_days: 90
      tags: module.tags.tags
```

---

## Naming Conventions

Default log group name resolves to:

```text
/pge-epic/<app_name>/<environment>/<log_group_name>
```

Default dashboard name resolves to:

```text
pge-epic-<app_name>-<environment>
```

---

## Terraform Compatibility

- Terraform >= 1.5
- AWS Provider >= 5.x

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.
