# EPIC AWS CloudTrail Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-cloudtrail
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS CloudTrail Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

> **Important — most CloudTrail controls are centralized.** Per the PG&E SAF 2.0 CloudTrail guardrail, the organization trail, log-archive S3 bucket, KMS key, MFA-Delete, lifecycle policy, and CloudWatch metric filters are owned by the **account bootstrap**, not by application stacks. Most EPIC consumers should NOT provision their own trail — the org-level trail already captures every API call any application resource makes.
>
> This module exists for the rare cases where an application-specific trail is required (tenant-scoped audit, narrow event-selector data-event capture, etc.). When you reach for it, re-read the guardrail and confirm a duplicate trail is actually warranted.

This module is intentionally **low-level and policy-agnostic** — the destination S3 bucket, its bucket policy, CloudWatch Logs role, and KMS key are inputs the caller has already composed.

---

## Design Principles

- Multi-region enforced
- Log file validation enforced
- Global service events captured
- Caller owns the destination S3 bucket and its policy
- Caller owns the KMS CMK (when used)
- Caller owns the CloudWatch Logs role + group (when CloudWatch integration is desired)

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions:

| SAF # | Control | Enforcement |
|---|---|---|
| #2 | PG&E-managed CMK | `kms_key_id` mandatory when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged` |
| #6 | Centralize logging | `is_multi_region_trail=true`, `enable_log_file_validation=true`, `include_global_service_events=true` enforced |

Out of module scope (caller composes): destination S3 bucket and bucket policy (use `epic-pipeline-module-aws-s3`), KMS CMK (use `epic-pipeline-module-aws-kms`), CloudWatch Logs role + group (use `epic-pipeline-module-aws-cloudwatch`), CloudTrail VPC endpoint.

---

## What This Module Is (and Is Not)

### This module IS
- A foundational application-specific trail primitive
- A surface for narrow event-selector configuration

### This module is NOT
- A log-archive S3 bucket module (use `epic-pipeline-module-aws-s3`)
- A KMS module (use `epic-pipeline-module-aws-kms`)
- A CloudWatch log group module (use `epic-pipeline-module-aws-cloudwatch`)
- A replacement for the centrally-managed org trail

---

## Resources Created

- `aws_cloudtrail`

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags |
| `s3_bucket_name` | Destination bucket (must already have a CloudTrail-friendly bucket policy) |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_trail_name` | Full trail name override | `null` |
| `s3_key_prefix` | S3 key prefix for log files | `null` |
| `include_global_service_events` | Capture IAM / CloudFront / etc. events | `true` |
| `is_multi_region_trail` | Capture events from all regions | `true` |
| `is_organization_trail` | Treat as an org-level trail | `false` |
| `enable_log_file_validation` | Enable log integrity validation | `true` |
| `enable_logging` | Start logging on create | `true` |
| `kms_key_id` | KMS key ARN for log encryption | `null` |
| `sns_topic_name` | SNS topic for delivery notifications | `null` |
| `cloudwatch_logs_group_arn` | CloudWatch Logs group ARN | `null` |
| `cloudwatch_logs_role_arn` | Role ARN CloudTrail uses to write to CloudWatch | `null` |
| `event_selectors` | Classic event selector objects | `[]` |
| `advanced_event_selectors` | Advanced event selectors (mutually exclusive) | `[]` |

---

## Outputs

| Name | Description |
|---|---|
| `trail_id` | Trail ID |
| `trail_arn` | Trail ARN |
| `trail_name` | Resolved trail name |
| `trail_home_region` | Home region |

---

## Example Usage (Direct Terraform)

```hcl
module "cloudtrail" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudtrail.git"

  app_name       = "nfr-tool"
  environment    = "dev"
  s3_bucket_name = module.trail_bucket.bucket_name
  kms_key_id     = module.trail_key.key_arn

  cloudwatch_logs_group_arn = module.trail_logs.log_group_arn
  cloudwatch_logs_role_arn  = aws_iam_role.cloudtrail_to_cloudwatch.arn

  event_selectors = [{
    read_write_type           = "All"
    include_management_events = true
    data_resources = [{
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::sensitive-bucket/"]
    }]
  }]

  tags = module.tags.tags
}
```

Resolves to trail name `pge-epic-nfr-tool-dev`.

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: app-trail
    path: epic-pipeline-module-aws-cloudtrail
    variables:
      app_name: ${app_name}
      environment: ${environment}
      s3_bucket_name: ${module.trail_bucket.bucket_name}
      tags: module.tags.tags
```

---

## Naming Conventions

Default trail name resolves to:

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
