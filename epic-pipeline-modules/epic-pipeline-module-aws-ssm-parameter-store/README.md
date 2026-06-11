# epic-pipeline-module-aws-ssm-parameter-store

## Overview

Provisions a single AWS Systems Manager (SSM) Parameter Store parameter for an EPIC application. Intended for non-secret runtime configuration (feature flags, endpoints, scheduling intervals, operations recipients) that the application or its Lambdas read at cold-start.

The module derives a standard parameter path from the EPIC identity (`app_name`, `environment`) and the caller-supplied `parameter_name`, applies common tags, and enforces SAF guardrails:

- `SecureString` requires a customer-managed `kms_key_id`.
- Parameter Store is rejected for `Confidential` / `Restricted` / `Privileged` data classifications — those values must use `epic-pipeline-module-aws-secretmanager`.

For credentials and other secret material, prefer `epic-pipeline-module-aws-secretmanager`.

---

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_ssm_parameter.this` | The parameter itself (path, value, type, optional KMS key, allowed pattern, tags). |

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name. Injected by EPIC. Used to build the parameter path. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). Injected by EPIC. |
| `tags` | `map(string)` | Common tags applied to the parameter. |
| `parameter_name` | `string` | Final segment of the parameter path. Combined into `/pge-epic/<app_name>/<environment>/<parameter_name>` unless `custom_name` is provided. |
| `value` | `string` | Parameter value. For `SecureString`, encrypted at rest under `kms_key_id`. Marked `sensitive`. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_name` | `string` | `null` | Full parameter path override. Takes precedence over the auto-derived name. |
| `description` | `string` | `null` | Human-readable description of the parameter. |
| `type` | `string` | `"String"` | One of `String`, `StringList`, `SecureString`. Use `String` for non-secret config; `SecureString` requires `kms_key_id` and is intentionally restricted (prefer `epic-pipeline-module-aws-secretmanager` for credentials). |
| `tier` | `string` | `"Standard"` | One of `Standard`, `Advanced`, `Intelligent-Tiering`. `Standard` supports values up to 4 KB; `Advanced` supports up to 8 KB and policies. |
| `data_type` | `string` | `"text"` | Use `text` for plain values; `aws:ec2:image` / `aws:ssm:integration` for AWS-validated content. |
| `kms_key_id` | `string` | `null` | KMS Key ARN or alias for `SecureString` encryption. Required when `type = "SecureString"`. |
| `allowed_pattern` | `string` | `null` | Regex pattern enforced at write time. |
| `overwrite` | `bool` | `true` | If `true`, an existing parameter with the same name is overwritten on apply. |

---

## Outputs

| Name | Description |
|------|-------------|
| `parameter_name` | Resolved parameter name (full path). |
| `parameter_arn` | Parameter ARN. |
| `parameter_version` | Parameter version. |
| `parameter_type` | Parameter type (`String`, `StringList`, or `SecureString`). |

---

## Usage in a Terraform project

The following is the canonical usage pattern from `projects/test-app/.infra/ssm.tf`. It illustrates the EPIC convention for mixing infrastructure-derived parameters (re-applied on every plan) with admin-editable parameters (`lifecycle { ignore_changes = [value] }` so operators can edit values via the AWS console without Terraform reverting them).

```hcl
###############################################################################
# SSM Parameter Store — non-secret runtime config per Requirements §3.6.7
# and create.md §10.9 (admin-editable parameters use ignore_changes = [value]).
###############################################################################

# Infrastructure-derived (not admin-editable) — re-applies on every plan.
resource "aws_ssm_parameter" "rds_proxy_endpoint" {
  name        = "/${var.project_tag}/${var.environment}/database/proxy-endpoint"
  description = "RDS Proxy endpoint that Lambdas read at cold-start (per create.md §10.1)."
  type        = "String"
  value       = module.rds_proxy.proxy_endpoint
  tags        = module.tags.tags
}

# Admin-editable, numeric knob — design pins default 24 (Requirements §3.6.7.1.a).
resource "aws_ssm_parameter" "dashboard_recompute_interval" {
  name        = "/${var.project_tag}/${var.environment}/dashboard/recompute-interval-hours"
  description = "Cadence at which nfr-dashboard-aggregator runs (Requirements §3.6.7.1.a). Range 1-24."
  type        = "String"
  value       = tostring(var.dashboard_recompute_interval_hours)
  tags        = module.tags.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Admin-editable, operations recipient — per create.md §10.9, the SAF Notify
# value is the right operationally-correct default (no TODO).
resource "aws_ssm_parameter" "ops_alert_recipient" {
  name        = "/${var.project_tag}/${var.environment}/ops/alert-recipient"
  description = "Operations alert recipient (admin-editable; defaults to the SAF Notify tag value)."
  type        = "String"
  value       = var.notify[0]
  tags        = module.tags.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Admin-editable, business-domain recipient — Requirements §3.6.7 names an
# MEA admin DL. Per create.md §10.9, business-domain recipients get a TODO
# placeholder, since silently defaulting to the Notify address risks mixing
# operations alerts with business notifications.
resource "aws_ssm_parameter" "mea_admin_distribution_list" {
  name        = "/${var.project_tag}/${var.environment}/admin/mea-distribution-list"
  description = "MEA admin distribution list (admin-editable; first deploy uses placeholder, admin UI overwrites)."
  type        = "String"
  value       = "TODO_MEA_ADMIN_DL_INITIAL_RECIPIENT"
  tags        = module.tags.tags

  lifecycle {
    ignore_changes = [value]
  }
}
```

When using this module instead of raw resources, each parameter is a separate module block. The path is auto-derived from the EPIC identity:

```hcl
module "dashboard_recompute_interval" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ssm-parameter-store.git?ref=main"

  app_name       = var.app_name
  environment    = var.environment
  tags           = module.tags.tags
  parameter_name = "dashboard/recompute-interval-hours"
  description    = "Cadence at which nfr-dashboard-aggregator runs. Range 1-24."
  value          = tostring(var.dashboard_recompute_interval_hours)
}
```

This produces a parameter at `/pge-epic/<app_name>/<environment>/dashboard/recompute-interval-hours`.

---

## Usage from another module

Compose this module inside a higher-level module by passing through the EPIC identity inputs (`app_name`, `environment`, `tags`) along with the parameter-specific inputs.

```hcl
module "feature_flag" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ssm-parameter-store.git?ref=main"

  app_name        = var.app_name
  environment     = var.environment
  tags            = var.tags
  parameter_name  = "features/new-checkout-flow"
  description     = "Feature flag for the new checkout flow."
  value           = "false"
  allowed_pattern = "^(true|false)$"
}

output "feature_flag_arn" {
  value = module.feature_flag.parameter_arn
}
```

Higher-level modules that manage many parameters can wrap this module in a `for_each` loop over a map of `{ parameter_name => value }` pairs.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

---

## Notes

- The default path format is `/pge-epic/<app_name>/<environment>/<parameter_name>`. Use `custom_name` only when integrating with a pre-existing path that does not match the EPIC convention.
- `kms_key_id` is honored only when `type = "SecureString"`; for other types the field on the underlying resource stays unset.
- Setting tag `DataClassification` to `Confidential`, `Restricted`, or `Privileged` causes the apply to fail by design — those values must live in Secrets Manager via `epic-pipeline-module-aws-secretmanager`.
- The module sets `overwrite = true` by default so re-applies adopt drifted values. Set `overwrite = false` to make apply fail when a parameter with the same name already exists outside Terraform.
- For admin-editable parameters whose value is meant to drift after first apply, consider managing those parameters as raw `aws_ssm_parameter` resources alongside this module so you can attach `lifecycle { ignore_changes = [value] }` directly, as shown in the canonical example above.
