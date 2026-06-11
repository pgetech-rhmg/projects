# epic-pipeline-module-aws-ses

## Overview

Terraform module that provisions an AWS SES configuration set for applications running under EPIC (Enterprise Pipeline for Infrastructure and Cloud).

The module creates a single configuration set with TLS-required delivery and an optional CloudWatch event destination. It is intentionally outbound-only: domain identity verification, IAM grants, template management, and bounce-handler plumbing live outside this module. Consumers wire those resources directly in their `.infra/` alongside the module call.

The default configuration set name resolves to `pge-epic-<app_name>-<environment>-ses` and can be overridden with `custom_configuration_set_name`.

---

## Resources

- `aws_ses_configuration_set`
- `aws_ses_event_destination` (optional, CloudWatch destination only)

---

## Inputs

### Required

| Name | Type | Description |
|---|---|---|
| `app_name` | `string` | Application name used for naming the SES configuration set. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |

### Optional

| Name | Type | Default | Description |
|---|---|---|---|
| `custom_configuration_set_name` | `string` | `null` | Full configuration set name override. Takes precedence over the auto-derived name. |
| `reputation_metrics_enabled` | `bool` | `true` | Whether reputation metrics (bounce / complaint rates) are emitted to CloudWatch. |
| `sending_enabled` | `bool` | `true` | Whether email sending is enabled for this configuration set. |
| `custom_redirect_domain` | `string` | `""` | Custom domain used in click-tracking redirects. Empty disables custom tracking. |
| `event_destination` | `object` | `null` | Optional CloudWatch event destination wired to this configuration set. See shape below. |

`event_destination` object shape:

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | yes | Event destination name. |
| `enabled` | `bool` | no (default `true`) | Whether the destination is enabled. |
| `matching_types` | `list(string)` | yes | Event types to forward, e.g. `["bounce", "complaint", "delivery", "send", "reject", "deliveryDelay"]`. |
| `default_value` | `string` | yes | CloudWatch dimension default value. |
| `dimension_name` | `string` | yes | CloudWatch dimension name. |
| `value_source` | `string` | yes | Dimension value source: `messageTag`, `emailHeader`, or `linkTag`. |

---

## Outputs

| Name | Description |
|---|---|
| `configuration_set_name` | SES configuration set name. |
| `configuration_set_arn` | SES configuration set ARN. |
| `event_destination_name` | Name of the SES event destination if managed by this module, otherwise `null`. |

---

## Usage in a Terraform Project

The canonical consumer is `projects/test-app/.infra/ses.tf`. The module manages only the configuration set; the sender domain identity and any SNS-routed event destinations are declared directly alongside the module call.

```hcl
module "ses" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ses.git?ref=main"

  app_name    = var.project_tag
  environment = var.environment

  reputation_metrics_enabled = true
  sending_enabled            = true
}

resource "aws_ses_domain_identity" "sender" {
  domain = var.ses_sender_domain
}

resource "aws_ses_event_destination" "bounce_to_sns" {
  name                   = "${var.project_tag}-bounce-to-sns-${var.environment}"
  configuration_set_name = module.ses.configuration_set_name
  enabled                = true
  matching_types         = ["bounce", "complaint", "reject"]

  sns_destination {
    topic_arn = module.sns_ses_bounce.topic_arn
  }
}
```

`app_name` and `environment` are typically sourced from inputs the EPIC engine threads through to the application's `.infra/` Terraform run, driven by the `app` section of `.pipeline/epic.json`.

To attach a CloudWatch event destination through the module instead of declaring one directly, pass the `event_destination` object:

```hcl
module "ses" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ses.git?ref=main"

  app_name    = var.project_tag
  environment = var.environment

  event_destination = {
    name           = "cloudwatch-events"
    matching_types = ["bounce", "complaint", "delivery", "send", "reject", "deliveryDelay"]
    default_value  = "default"
    dimension_name = "ses:source-ip"
    value_source   = "messageTag"
  }
}
```

---

## Usage from Another Module

```hcl
module "ses" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ses.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
}

output "ses_configuration_set_name" {
  value = module.ses.configuration_set_name
}

output "ses_configuration_set_arn" {
  value = module.ses.configuration_set_arn
}
```

---

## Versions

| Requirement | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

---

## Notes

- TLS is hardcoded to `Require` in `delivery_options` and is not user-configurable.
- SES configuration sets and event destinations do not support resource tags, so the module does not accept a `tags` input.
- The module's `event_destination` block is CloudWatch-shaped only. SNS event destinations must be declared directly via `aws_ses_event_destination` and pointed at `module.ses.configuration_set_name`, as shown in `projects/test-app/.infra/ses.tf`.
- Domain identity verification, IAM `ses:SendEmail` grants, sandbox removal, and bounce-handler queues are out of scope for this module.
