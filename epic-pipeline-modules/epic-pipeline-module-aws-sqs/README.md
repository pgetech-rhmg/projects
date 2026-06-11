# EPIC AWS SQS Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-sqs
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS SQS Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module creates a single SQS queue (Standard or FIFO) with sane defaults aligned to the PG&E SAF 2.0 SQS guardrails. It is intentionally **low-level and policy-agnostic** — VPC endpoints, IAM grants, and CloudWatch alarms are composed by higher-level modules or by the consuming application.

---

## Design Principles

- Secure by default (SSE-required, long retention for DLQs)
- One queue per module instance
- Naming convention enforced by default (`pge-epic-<app>-<env>-<name>[.fifo]`)
- Caller-owned access policy (no embedded `Principal: '*'` allowed)
- Compatible with EPIC auto-wiring and orchestration

---

## What This Module Is (and Is Not)

### This module IS
- A foundational SQS queue primitive
- A consistent naming surface for queue resources
- Suitable for direct use by experienced Terraform users

### This module is NOT
- A DLQ wiring layer (caller passes `redrive_policy` JSON to wire DLQs)
- A VPC endpoint module
- A CloudWatch alarm module
- A place to embed organization-specific access rules

---

## Resources Created

- `aws_sqs_queue`
- Optional: `aws_sqs_queue_policy` (only when provided by the caller)

---

## Security Defaults

- 14-day `message_retention_seconds` (matches SAF DLQ recommendation; override per-queue)
- KMS CMK is the recommended encryption path; `sqs_managed_sse_enabled` available when only `Internal` data flows
- Default queue policy synthesized to SAF shape (TLS-only Allow + DenyFromInternet) when `queue_policy_json` is null

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions and validations:

| SAF # | Control | Enforcement |
|---|---|---|
| #1 | Encrypt data at rest | One of `kms_master_key_id` (CMK) or `sqs_managed_sse_enabled=true` is required |
| #2 | PG&E-managed CMK | `kms_master_key_id` mandatory when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged` |
| #3 | TLS ≥ 1.2 | Default policy includes `aws:SecureTransport=true` Allow condition |
| #19 / #21 | Internet segregation | Default policy includes `DenyFromInternet` deny statement scoped to PG&E CIDR space |
| #29 | Least-privilege | `Principal: '*'` is forbidden by the default policy shape; caller passes specific role ARNs in `allowed_principal_arns` |

Default policy is generated when `queue_policy_json` is null. Caller must supply at least one of `queue_policy_json` or `allowed_principal_arns`.

Out of module scope: SQS VPC endpoint provisioning, IAM consumer-role grants, CloudWatch alarms (use `epic-pipeline-module-aws-cloudwatch-alarm`).

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags |
| `queue_name` | Logical queue name suffix |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_queue_name` | Full queue name override | `null` |
| `fifo_queue` | Create a FIFO queue (`.fifo` suffix appended) | `false` |
| `content_based_deduplication` | Enable content-based dedup (FIFO only) | `false` |
| `deduplication_scope` | `messageGroup` or `queue` (FIFO only) | `null` |
| `fifo_throughput_limit` | `perQueue` or `perMessageGroupId` (FIFO only) | `null` |
| `delay_seconds` | Delivery delay (0–900) | `0` |
| `max_message_size` | Max bytes per message (1024–262144) | `262144` |
| `message_retention_seconds` | Retention window (60–1209600) | `1209600` |
| `receive_wait_time_seconds` | Long-polling wait (0–20) | `0` |
| `visibility_timeout_seconds` | Visibility timeout (0–43200) | `30` |
| `kms_master_key_id` | CMK for SSE-KMS | `null` |
| `kms_data_key_reuse_period_seconds` | Data key reuse window | `300` |
| `sqs_managed_sse_enabled` | AWS-managed SSE when no CMK provided | `false` |
| `redrive_policy` | JSON redrive policy (DLQ wiring) | `null` |
| `redrive_allow_policy` | JSON redrive allow policy | `null` |
| `queue_policy_json` | Raw JSON access policy override | `null` |
| `allowed_principal_arns` | Principal ARNs for the synthesized SAF default policy | `[]` |
| `internal_cidr_blocks` | CIDRs allowed by the synthesized DenyFromInternet | PG&E ranges |

---

## Outputs

| Name | Description |
|---|---|
| `queue_id` | Queue URL (ID) |
| `queue_url` | Queue URL |
| `queue_arn` | Queue ARN |
| `queue_name` | Queue name |

---

## Example Usage (Direct Terraform)

```hcl
module "aggregator_dlq" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sqs.git"

  app_name    = "nfr-tool"
  environment = "dev"
  queue_name  = "aggregator-dlq"

  kms_master_key_id          = module.kms.key_arn
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 60

  allowed_principal_arns = [aws_iam_role.aggregator.arn]

  tags = module.tags.tags
}
```

Wire a primary queue to that DLQ:

```hcl
module "primary_queue" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sqs.git"

  app_name    = "nfr-tool"
  environment = "dev"
  queue_name  = "ingest"

  kms_master_key_id = module.kms.key_arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.aggregator_dlq.queue_arn
    maxReceiveCount     = 5
  })

  tags = module.tags.tags
}
```

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: aggregator-dlq
    path: epic-pipeline-module-aws-sqs
    variables:
      app_name: ${app_name}
      environment: ${environment}
      queue_name: aggregator-dlq
      kms_master_key_id: ${module.kms.key_arn}
      tags: module.tags.tags
```

---

## Naming Conventions

Default name resolves to:

```text
pge-epic-<app_name>-<environment>-<queue_name>[.fifo]
```

Example:

```text
pge-epic-nfr-tool-prod-aggregator-dlq
pge-epic-nfr-tool-prod-ingest.fifo
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
