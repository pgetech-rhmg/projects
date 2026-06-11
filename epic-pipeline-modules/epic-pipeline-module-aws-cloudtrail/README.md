# EPIC AWS CloudTrail Module

## Overview

Provisions an AWS CloudTrail trail for an EPIC-managed application. The module produces a single multi-region trail wired to a caller-supplied S3 bucket, with optional CloudWatch Logs integration, SNS notifications, KMS encryption, and event/data selectors.

The trail name defaults to `pge-epic-{app_name}-{environment}` and can be overridden via `custom_trail_name`. SAF (Security Architecture Framework) preconditions enforce multi-region coverage, log file integrity validation, global service event capture, and a customer-managed KMS key when the `DataClassification` tag is `Confidential`, `Restricted`, or `Privileged`.

This module is intended to be consumed from an application's `.infra/` Terraform configuration. EPIC reads `.pipeline/epic.json` and runs `terraform apply` against `.infra/` during the DeployInfra stage.

## Resources

| Resource | Type |
|----------|------|
| `aws_cloudtrail.this` | `aws_cloudtrail` |

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used to derive the trail name. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `tags` | `map(string)` | Common tags applied to the trail. `DataClassification` is inspected to enforce CMK requirements. |
| `s3_bucket_name` | `string` | S3 bucket where trail logs are written. The bucket must already have a CloudTrail-friendly bucket policy. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_trail_name` | `string` | `null` | Full trail name override. Takes precedence over the auto-derived name. |
| `s3_key_prefix` | `string` | `null` | Optional key prefix for trail logs in the destination bucket. |
| `include_global_service_events` | `bool` | `true` | Capture global service events (IAM, CloudFront, etc.). Must remain `true` to satisfy SAF Item #6. |
| `is_multi_region_trail` | `bool` | `true` | Capture events from all regions. Must remain `true` to satisfy SAF Item #6. |
| `is_organization_trail` | `bool` | `false` | Whether the trail is an organization trail. Almost always `false` at the application level. |
| `enable_log_file_validation` | `bool` | `true` | Enable log file integrity validation. Must remain `true` to satisfy SAF Item #6. |
| `enable_logging` | `bool` | `true` | Whether the trail starts logging on creation. |
| `kms_key_id` | `string` | `null` | KMS key ARN used to encrypt log files. Required when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged`. |
| `sns_topic_name` | `string` | `null` | SNS topic name for log file delivery notifications. |
| `cloudwatch_logs_group_arn` | `string` | `null` | CloudWatch Logs group ARN. Both this and `cloudwatch_logs_role_arn` must be set to enable CloudWatch integration. |
| `cloudwatch_logs_role_arn` | `string` | `null` | IAM role ARN CloudTrail assumes when delivering logs to CloudWatch. |
| `event_selectors` | `list(object)` | `[]` | Basic event selectors. Each item: `read_write_type` (`All`/`ReadOnly`/`WriteOnly`), `include_management_events` (`bool`), `data_resources` (optional list of `{ type, values }`). |
| `advanced_event_selectors` | `any` | `[]` | Advanced event selectors. Mutually exclusive with `event_selectors`. Pass-through to `aws_cloudtrail`. |

## Outputs

| Name | Description |
|------|-------------|
| `trail_id` | CloudTrail ID. |
| `trail_arn` | CloudTrail ARN. |
| `trail_name` | CloudTrail name. |
| `trail_home_region` | Home region for the trail. |

## Usage in a Terraform Project

Consumed from an application's `.infra/main.tf`. Inputs `app_name`, `environment`, and `tags` typically come from `.pipeline/epic.json`-derived locals or `terraform.auto.tfvars`.

```hcl
module "cloudtrail" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudtrail.git?ref=main"

  app_name       = var.app_name
  environment    = var.environment
  s3_bucket_name = "pge-epic-${var.app_name}-trail-logs-${var.environment}"

  kms_key_id = aws_kms_key.trail.arn

  cloudwatch_logs_group_arn = aws_cloudwatch_log_group.trail.arn
  cloudwatch_logs_role_arn  = aws_iam_role.cloudtrail_to_cwl.arn

  event_selectors = [
    {
      read_write_type           = "All"
      include_management_events = true
      data_resources = [
        {
          type   = "AWS::S3::Object"
          values = ["arn:aws:s3:::pge-epic-${var.app_name}-${var.environment}/"]
        }
      ]
    }
  ]

  tags = {
    Application        = var.app_name
    Environment        = var.environment
    DataClassification = "Confidential"
    ManagedBy          = "EPIC"
  }
}
```

## Usage From Another Module

Compose this module inside a higher-level account-baseline or secure-landing-zone module that wires CloudTrail to a shared logging bucket and KMS key:

```hcl
module "audit_trail" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudtrail.git?ref=main"

  app_name       = local.account_baseline_name
  environment    = var.environment
  s3_bucket_name = module.log_archive_bucket.bucket_name
  s3_key_prefix  = "cloudtrail/${var.environment}"

  kms_key_id = module.audit_kms.key_arn

  is_organization_trail = false

  tags = merge(var.tags, {
    DataClassification = "Restricted"
  })
}

output "audit_trail_arn" {
  value = module.audit_trail.trail_arn
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- `is_multi_region_trail`, `enable_log_file_validation`, and `include_global_service_events` are guarded by lifecycle preconditions and cannot be disabled.
- CloudWatch integration is all-or-nothing: both `cloudwatch_logs_group_arn` and `cloudwatch_logs_role_arn` must be supplied, otherwise neither is wired.
- `event_selectors` and `advanced_event_selectors` are mutually exclusive at the AWS API level; supply only one.
- The destination S3 bucket and any KMS key, CloudWatch log group, IAM role, or SNS topic are not created by this module and must exist before `apply`.
