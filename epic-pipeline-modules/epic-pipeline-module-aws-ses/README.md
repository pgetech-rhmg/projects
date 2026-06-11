# EPIC AWS SES Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-ses
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS SES Configuration Set Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

The module creates a single SES configuration set with TLS-required delivery and an optional CloudWatch event destination. It is intentionally **outbound-only** and **policy-agnostic** — domain identity verification, sandbox removal, IAM grants, VPC endpoints, and template management are owned by higher-level modules or the central email team.

> SES is **not approved for Confidential / Restricted / Privileged data** per PG&E SAF Item #9. Notification bodies must be metadata + deep link only.

> SES configuration sets and event destinations do not support resource tags, so this module does not accept a `tags` input.

---

## Design Principles

- TLS required (cannot be disabled via this module)
- Reputation metrics enabled by default
- Outbound-only — no receipt rule sets, no inbound buckets
- Naming convention enforced by default (`pge-epic-<app>-<env>-ses`)
- Caller wires CloudWatch event destination as needed

---

## SAF 2.0 Compliance

| SAF # | Control | Enforcement |
|---|---|---|
| #3 / #25 | TLS ≥ 1.2 | `tls_policy=Require` hardcoded — not user-configurable |
| #9 | Sensitivity classification | Per the SAF, SES is not approved for Confidential data — enforced by content discipline (notification body = metadata + deep link), not by this module |
| #11 / #12 / #17 | Tags | SES configuration sets do not support tags — module deliberately does not accept a `tags` input |

Out of module scope: domain identity verification (owned by the IT email team), bounce-handler queue (use `epic-pipeline-module-aws-sqs`), SES VPC endpoint, IAM `ses:SendEmail` grants on consumer roles.

---

## What This Module Is (and Is Not)

### This module IS
- A foundational SES configuration set primitive
- A TLS-required delivery surface
- An optional CloudWatch event destination wiring

### This module is NOT
- A domain verification module (verification is owned by IT email team)
- A receipt rule module (NFR Tool / EPIC consumers do not receive)
- A template manager
- A bounce-handler queue (use `epic-pipeline-module-aws-sqs` for that)

---

## Resources Created

- `aws_ses_configuration_set`
- Optional: `aws_ses_event_destination` (CloudWatch destination)

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_configuration_set_name` | Full name override | `null` |
| `reputation_metrics_enabled` | Emit bounce/complaint metrics | `true` |
| `sending_enabled` | Enable email sending | `true` |
| `custom_redirect_domain` | Click-tracking redirect domain | `""` |
| `event_destination` | CloudWatch event destination object | `null` |

---

## Outputs

| Name | Description |
|---|---|
| `configuration_set_name` | Configuration set name |
| `configuration_set_arn` | Configuration set ARN |
| `event_destination_name` | Event destination name when managed |

---

## Example Usage (Direct Terraform)

```hcl
module "ses" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ses.git"

  app_name    = "nfr-tool"
  environment = "dev"

  event_destination = {
    name           = "cloudwatch-events"
    matching_types = ["bounce", "complaint", "delivery", "send", "reject", "deliveryDelay"]
    default_value  = "default"
    dimension_name = "ses:source-ip"
    value_source   = "messageTag"
  }
}
```

Resolves to configuration set `pge-epic-nfr-tool-dev-ses`.

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: ses
    path: epic-pipeline-module-aws-ses
    variables:
      app_name: ${app_name}
      environment: ${environment}
```

---

## Naming Conventions

Default name resolves to:

```text
pge-epic-<app_name>-<environment>-ses
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
