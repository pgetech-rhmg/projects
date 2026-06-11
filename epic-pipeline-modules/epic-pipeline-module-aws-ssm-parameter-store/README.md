# EPIC AWS SSM Parameter Store Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-ssm-parameter-store
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS Systems Manager Parameter Store Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module manages a single SSM parameter and is designed to be reused per parameter. It is intentionally **low-level and policy-agnostic** — IAM grants, VPC endpoints, and admin-write surfaces are composed by higher-level modules or by the consuming application.

Per PG&E SAF 2.0 SSM Parameter Store guardrails, **Parameter Store is not a secrets store** — credentials, API keys, and database connection strings belong in [epic-pipeline-module-aws-secretmanager](../epic-pipeline-module-aws-secretmanager/). `SecureString` is supported here for cases where it is unavoidable, but the default and recommended type is `String`.

---

## Design Principles

- Secure by default
- One parameter per module instance — predictable IAM scoping
- Naming convention enforced by default (`/pge-epic/<app>/<env>/<name>`)
- `SecureString` requires an explicit CMK
- No embedded access policy logic
- Compatible with EPIC auto-wiring and orchestration

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions:

| SAF # | Control | Enforcement |
|---|---|---|
| #2 | PG&E-managed CMK | `kms_key_id` required when `type=SecureString` |
| #5 | Approved secret store | Parameter Store rejects `tags["DataClassification"]` of `Confidential`, `Restricted`, or `Privileged` — credentials and API keys belong in `epic-pipeline-module-aws-secretmanager` |

Out of module scope: SSM VPC endpoint, IAM `ssm:GetParameter` / `ssm:PutParameter` grants, parameter-change EventBridge wiring.

---

## What This Module Is (and Is Not)

### This module IS
- A foundational SSM parameter primitive
- A consistent naming surface for application config
- Suitable for direct use by experienced Terraform users

### This module is NOT
- A secrets manager (use `epic-pipeline-module-aws-secretmanager`)
- A parameter-hierarchy builder (call it once per parameter)
- A place to embed VPC endpoint or IAM-policy logic

---

## Resources Created

- `aws_ssm_parameter`

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags |
| `parameter_name` | Final segment of the parameter path |
| `value` | Parameter value |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_name` | Full parameter path override | `null` |
| `description` | Human-readable description | `null` |
| `type` | `String`, `StringList`, or `SecureString` | `String` |
| `tier` | `Standard`, `Advanced`, or `Intelligent-Tiering` | `Standard` |
| `data_type` | `text`, `aws:ec2:image`, `aws:ssm:integration` | `text` |
| `kms_key_id` | KMS key for `SecureString` (required if type is `SecureString`) | `null` |
| `allowed_pattern` | Regex enforced on value | `null` |
| `overwrite` | Overwrite existing parameter on apply | `true` |

---

## Outputs

| Name | Description |
|---|---|
| `parameter_name` | Resolved parameter path |
| `parameter_arn` | Parameter ARN |
| `parameter_version` | Parameter version |
| `parameter_type` | Resolved type |

---

## Example Usage (Direct Terraform)

```hcl
module "recompute_interval" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ssm-parameter-store.git"

  app_name       = "nfr-tool"
  environment    = "dev"
  parameter_name = "dashboard/recompute-interval-hours"
  value          = "24"
  description    = "Hours between dashboard aggregator runs."

  tags = module.tags.tags
}
```

Resolves to `/pge-epic/nfr-tool/dev/dashboard/recompute-interval-hours`.

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: dashboard-interval
    path: epic-pipeline-module-aws-ssm-parameter-store
    variables:
      app_name: ${app_name}
      environment: ${environment}
      parameter_name: dashboard/recompute-interval-hours
      value: "24"
      tags: module.tags.tags
```

---

## Naming Conventions

Default name resolves to:

```text
/pge-epic/<app_name>/<environment>/<parameter_name>
```

Example:

```text
/pge-epic/nfr-tool/prod/dashboard/recompute-interval-hours
```

Use `custom_name` to bypass the convention.

---

## Terraform Compatibility

- Terraform >= 1.5
- AWS Provider >= 5.x

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.
