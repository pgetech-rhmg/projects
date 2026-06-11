# epic-pipeline-module-aws-dynamodb

Terraform module that provisions a single AWS DynamoDB table for applications running under EPIC. Designed to be invoked once per table (typically via `for_each`) from an application's `.infra/` directory referenced by `.pipeline/epic.json`.

## Overview

The module creates one `aws_dynamodb_table` with a configurable hash key, optional range key, optional global secondary indexes, optional DynamoDB Streams, optional TTL, and standard safety controls (deletion protection, point-in-time recovery). It defaults to on-demand billing (`PAY_PER_REQUEST`) and the latest stream view (`NEW_AND_OLD_IMAGES`) when streams are enabled.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_dynamodb_table.this` | The DynamoDB table, including key schema, attributes, GSIs, stream, TTL, deletion protection, and PITR |

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `table_name` | `string` | DynamoDB table name |
| `hash_key` | `string` | Partition key attribute name |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `billing_mode` | `string` | `"PAY_PER_REQUEST"` | Billing mode. One of `PAY_PER_REQUEST`, `PROVISIONED` |
| `hash_key_type` | `string` | `"S"` | Partition key attribute type (`S`, `N`, or `B`) |
| `range_key` | `string` | `null` | Sort key attribute name |
| `range_key_type` | `string` | `"S"` | Sort key attribute type (`S`, `N`, or `B`) |
| `global_secondary_indexes` | `list(object)` | `[]` | GSI definitions: `name`, `hash_key`, optional `range_key`, `projection_type` (default `ALL`), `non_key_attributes` |
| `additional_attributes` | `list(object({name,type}))` | `[]` | Extra attribute definitions referenced by GSIs |
| `stream_enabled` | `bool` | `false` | Enable DynamoDB Streams |
| `stream_view_type` | `string` | `"NEW_AND_OLD_IMAGES"` | Stream view type. One of `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES`. Ignored when `stream_enabled = false` |
| `ttl_attribute` | `string` | `null` | TTL attribute name. When set, TTL is enabled on this attribute |
| `deletion_protection_enabled` | `bool` | `false` | Enable deletion protection |
| `point_in_time_recovery` | `bool` | `false` | Enable point-in-time recovery |
| `tags` | `map(string)` | `{}` | Tags applied to the table |

## Outputs

| Name | Description |
|------|-------------|
| `table_name` | DynamoDB table name |
| `table_arn` | DynamoDB table ARN |
| `table_id` | DynamoDB table ID |
| `stream_arn` | DynamoDB stream ARN (null when streams are disabled) |

## Usage in a Terraform project

Direct call from an application's `.infra/` directory. Each invocation creates one table.

```hcl
module "submissions_table" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-dynamodb.git?ref=main"

  table_name     = "${var.project_tag}-Submissions-${var.environment}"
  hash_key       = "submissionId"
  stream_enabled = true

  global_secondary_indexes = [
    { name = "learnerCorpId-index", hash_key = "learnerCorpId" },
    { name = "certId-index", hash_key = "certId" },
    { name = "status-index", hash_key = "status" }
  ]

  additional_attributes = [
    { name = "learnerCorpId", type = "S" },
    { name = "certId", type = "S" },
    { name = "status", type = "S" }
  ]

  deletion_protection_enabled = var.environment == "prod"
  tags                        = module.tags.tags
}
```

## Usage from another module (composition)

For applications with many tables, define a `local` map of table specs and fan out via `for_each`. This is the canonical pattern used by `cma-react-app` (`backend/.infra/dynamodb.tf`):

```hcl
locals {
  tables = {
    certifications = {
      table_name = "${var.project_tag}-Certifications-${var.environment}"
      hash_key   = "certId"
    }
    categories = {
      table_name = "${var.project_tag}-Categories-${var.environment}"
      hash_key   = "domainSlug"
      range_key  = "categoryName"
    }
    pairings = {
      table_name = "${var.project_tag}-Pairings-${var.environment}"
      hash_key   = "pairingId"
      global_secondary_indexes = [
        { name = "mentorId-index", hash_key = "mentorId" }
      ]
      additional_attributes = [{ name = "mentorId", type = "S" }]
    }
    notifications = {
      table_name    = "${var.project_tag}-Notifications-${var.environment}"
      hash_key      = "corpId"
      range_key     = "notificationId"
      ttl_attribute = "expiresAt"
      global_secondary_indexes = [
        { name = "unread-index", hash_key = "corpId", range_key = "isRead" }
      ]
      additional_attributes = [{ name = "isRead", type = "S" }]
    }
  }
}

module "dynamodb" {
  source   = "git::https://github.com/pgetech/epic-pipeline-module-aws-dynamodb.git?ref=main"
  for_each = local.tables

  table_name                  = each.value.table_name
  hash_key                    = each.value.hash_key
  range_key                   = try(each.value.range_key, null)
  stream_enabled              = try(each.value.stream_enabled, false)
  ttl_attribute               = try(each.value.ttl_attribute, null)
  global_secondary_indexes    = try(each.value.global_secondary_indexes, [])
  additional_attributes       = try(each.value.additional_attributes, [])
  deletion_protection_enabled = var.environment == "prod"
  tags                        = module.tags.tags
}
```

Reference outputs by table key, for example `module.dynamodb["submissions"].table_arn` when granting Lambda IAM permissions.

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS provider | `~> 5.90` |

## Notes

- Every attribute referenced by a GSI must be declared in `additional_attributes`. The hash and range key attributes are declared automatically; only extra attributes need to be listed.
- `stream_view_type` is only applied when `stream_enabled = true`; otherwise it is forced to `null` to avoid plan churn.
- The module does not configure provisioned capacity. Use `billing_mode = "PROVISIONED"` only if you also manage capacity outside the module.
