# epic-pipeline-module-aws-sqs

## Overview

Provisions an AWS SQS queue (standard or FIFO) with encryption, an attached resource policy, and optional dead-letter wiring. The module enforces SAF guardrails through `lifecycle` preconditions: encryption at rest is mandatory, a CMK is required when the `DataClassification` tag is `Confidential`, `Restricted`, or `Privileged`, and a queue policy must always resolve.

Queue names are derived as `pge-epic-<app_name>-<environment>-<queue_name>`. For FIFO queues the `.fifo` suffix is appended automatically. Use `custom_queue_name` to override the full name.

## Resources

- `aws_sqs_queue.this`
- `aws_sqs_queue_policy.this`
- `data.aws_iam_policy_document.saf_default` (synthesized when `queue_policy_json` is not supplied)

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used in the queue name. Injected by EPIC. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). Injected by EPIC. |
| `tags` | `map(string)` | Common tags. `DataClassification` drives the CMK precondition. |
| `queue_name` | `string` | Logical queue suffix combined into `pge-epic-<app_name>-<environment>-<queue_name>`. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_queue_name` | `string` | `null` | Full queue name override. Takes precedence over the auto-derived name. |
| `fifo_queue` | `bool` | `false` | Create a FIFO queue. The `.fifo` suffix is added automatically. |
| `content_based_deduplication` | `bool` | `false` | Enable content-based deduplication. Only valid when `fifo_queue` is true. |
| `deduplication_scope` | `string` | `null` | FIFO deduplication scope (`messageGroup` or `queue`). |
| `fifo_throughput_limit` | `string` | `null` | FIFO throughput limit (`perQueue` or `perMessageGroupId`). |
| `delay_seconds` | `number` | `0` | Delivery delay (0 to 900). |
| `max_message_size` | `number` | `262144` | Maximum message size in bytes (1024 to 262144). |
| `message_retention_seconds` | `number` | `1209600` | Retention period (60 to 1209600). DLQs default to 14 days per SAF guidance. |
| `receive_wait_time_seconds` | `number` | `0` | Long-polling wait (0 to 20). Set to `20` for long polling. |
| `visibility_timeout_seconds` | `number` | `30` | Visibility timeout in seconds (0 to 43200). |
| `kms_master_key_id` | `string` | `null` | KMS Key ARN or alias for SSE-KMS. Required when `DataClassification` is high. |
| `kms_data_key_reuse_period_seconds` | `number` | `300` | Data key reuse period (60 to 86400). |
| `sqs_managed_sse_enabled` | `bool` | `false` | Enable SSE-SQS when no `kms_master_key_id` is provided. |
| `redrive_policy` | `string` | `null` | JSON-encoded redrive policy (`deadLetterTargetArn` + `maxReceiveCount`). |
| `redrive_allow_policy` | `string` | `null` | JSON-encoded redrive allow policy. |
| `queue_policy_json` | `string` | `null` | Raw JSON queue policy. When omitted, a SAF-aligned default is synthesized. |
| `allowed_principal_arns` | `list(string)` | `[]` | Principal ARNs for the synthesized SAF default policy. Required when `queue_policy_json` is null. |
| `internal_cidr_blocks` | `list(string)` | PG&E internal ranges | CIDR blocks used by the synthesized `DenyFromInternet` condition. |

## Outputs

| Name | Description |
|------|-------------|
| `queue_id` | Queue URL (also serves as the resource ID). |
| `queue_url` | Queue URL. |
| `queue_arn` | Queue ARN. |
| `queue_name` | Resolved queue name. |

## Usage in a Terraform project

This module is consumed from an application's `.infra/` directory. EPIC injects `app_name`, `environment`, and `tags` via Terraform variables wired up by the engine.

```hcl
module "ingest_queue" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sqs.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags

  queue_name                 = "ingest"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 345600

  kms_master_key_id      = aws_kms_key.queues.arn
  allowed_principal_arns = [aws_iam_role.consumer.arn]
}

module "ingest_dlq" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sqs.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags

  queue_name             = "ingest-dlq"
  kms_master_key_id      = aws_kms_key.queues.arn
  allowed_principal_arns = [aws_iam_role.consumer.arn]
}
```

To wire the DLQ, set `redrive_policy` on the source queue:

```hcl
redrive_policy = jsonencode({
  deadLetterTargetArn = module.ingest_dlq.queue_arn
  maxReceiveCount     = 5
})
```

The matching `.pipeline/epic.json` declares the application and points at the infra directory:

```json
{
  "app": {
    "appName": "my-api",
    "appType": "python",
    "codePath": "/",
    "infraPath": ".infra"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2"
  }
}
```

## Usage from another module

```hcl
module "events_queue" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sqs.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags

  queue_name                  = "events"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  kms_master_key_id      = var.kms_key_arn
  allowed_principal_arns = var.consumer_role_arns
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- When `queue_policy_json` is null, the module synthesizes a policy that grants `allowed_principal_arns` queue access over TLS and denies any non-AWS-service traffic from outside `internal_cidr_blocks`. Supplying `queue_policy_json` replaces this entirely.
- Setting `kms_master_key_id` selects SSE-KMS; setting `sqs_managed_sse_enabled = true` (with no key) selects SSE-SQS. One of the two must be true or the precondition fails.
- When `DataClassification` in `tags` is `Confidential`, `Restricted`, or `Privileged`, `kms_master_key_id` is mandatory and `sqs_managed_sse_enabled` is not sufficient.
- FIFO-only inputs (`content_based_deduplication`, `deduplication_scope`, `fifo_throughput_limit`) are ignored when `fifo_queue` is false.
