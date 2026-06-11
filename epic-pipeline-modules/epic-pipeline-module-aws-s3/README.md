# epic-pipeline-module-aws-s3

Provisions an S3 bucket with EPIC's standard hardening: ownership controls, public access block, versioning, server-side encryption, optional access logging, optional lifecycle rules, optional bucket policy, and an optional one-shot object upload.

## Resources Created

- `aws_s3_bucket.this`
- `aws_s3_bucket_ownership_controls.this`
- `aws_s3_bucket_public_access_block.this` (when `enable_public_access_block`)
- `aws_s3_bucket_versioning.this`
- `aws_s3_bucket_server_side_encryption_configuration.this`
- `aws_s3_bucket_logging.this` (when `enable_access_logging`)
- `aws_s3_bucket_lifecycle_configuration.this` (when `lifecycle_rules` is non-empty)
- `aws_s3_bucket_policy.this` (when `bucket_policy_json` is set)
- `aws_s3_object.upload` (when `upload_object` is set)

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name; used to derive the default bucket name. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `tags` | `map(string)` | Common tags applied to the bucket. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_bucket_name` | `string` | `null` | Override the generated bucket name. When null, name is `pge-epic-<app_name>-<environment>`. |
| `force_destroy` | `bool` | `false` | Allow Terraform to delete the bucket even if it contains objects. |
| `object_ownership` | `string` | `BucketOwnerEnforced` | One of `BucketOwnerEnforced`, `BucketOwnerPreferred`, `ObjectWriter`. |
| `enable_public_access_block` | `bool` | `true` | Block all public access at the bucket level. |
| `enable_versioning` | `bool` | `false` | Enable S3 versioning. |
| `sse_algorithm` | `string` | `AES256` | One of `AES256` or `aws:kms`. |
| `kms_key_arn` | `string` | `null` | KMS key ARN. Required when `sse_algorithm = "aws:kms"`. |
| `enable_access_logging` | `bool` | `false` | Enable S3 server access logging. |
| `access_log_bucket` | `string` | `null` | Target bucket for access logs. Required when `enable_access_logging` is true. |
| `access_log_prefix` | `string` | `null` | Prefix applied to access log objects. |
| `lifecycle_rules` | `any` | `[]` | List of lifecycle rule objects (see below). |
| `bucket_policy_json` | `string` | `null` | Raw JSON bucket policy to attach. |
| `upload_object` | `object({ key, source })` | `null` | Optional file to upload after the bucket is created. |

`lifecycle_rules` element shape:

- `id` (string, required)
- `status` (string, required) — `Enabled` or `Disabled`
- `prefix` (string, optional, deprecated by AWS but accepted)
- `filter` (object, optional) — passed through; supports `{ prefix = "..." }` or `{ and = { prefix, tags } }`
- `transitions` (list of `{ days, storage_class }`, optional)
- `expiration` (`{ days }`, optional)
- `noncurrent_version_expiration` (`{ noncurrent_days }`, optional)

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | Bucket name (ID). |
| `bucket_arn` | Bucket ARN. |
| `bucket_domain_name` | Bucket domain name. |
| `bucket_regional_domain_name` | Regional domain name (use this for CloudFront origins). |

## Usage in a Terraform Project

Called from a project's `.infra/main.tf`. Example from `epic-api/.infra/main.tf`:

```hcl
module "s3_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "${var.app_name}-api-deploy"
  environment                = var.environment
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = var.access_log_prefix
  custom_bucket_name         = var.custom_bucket_name
  bucket_policy_json         = var.bucket_policy_json
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = var.enable_public_access_block
  enable_versioning          = var.enable_versioning
  force_destroy              = var.force_s3_destroy
  kms_key_arn                = var.kms_key_arn
  lifecycle_rules            = var.lifecycle_rules
  object_ownership           = var.object_ownership
  sse_algorithm              = var.sse_algorithm
}
```

`var.app_name`, `var.environment`, and the surrounding tag/network inputs are populated by the EPIC engine from the project's `.pipeline/epic.json` and the project's Terraform variables.

## Composition From Another Module

Calling this module from a higher-level composition module (e.g. a CloudFront-fronted static site that bundles its own bucket) follows the same pattern. The S3 outputs feed directly into a CloudFront origin — this is the shape used in `epic-web/.infra/main.tf`:

```hcl
module "s3_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name    = "${var.app_name}-web"
  environment = var.environment
  tags        = module.tags.tags

  enable_versioning          = var.enable_versioning
  enable_public_access_block = var.enable_public_access_block
  bucket_policy_json         = var.bucket_policy_json
  sse_algorithm              = var.sse_algorithm
  kms_key_arn                = var.kms_key_arn
}

module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  bucket_name                 = module.s3_web.bucket_name
  bucket_arn                  = module.s3_web.bucket_arn
  bucket_regional_domain_name = module.s3_web.bucket_regional_domain_name
  # ...
}
```

## Requirements

| Requirement | Version |
|-------------|---------|
| Terraform   | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- Default bucket name is `pge-epic-<app_name>-<environment>`. Override with `custom_bucket_name` only when global uniqueness or external naming requires it.
- Setting `sse_algorithm = "aws:kms"` without a `kms_key_arn` fails the bucket-encryption precondition at plan time.
- Setting `enable_access_logging = true` without `access_log_bucket` fails the logging precondition at plan time.
- `upload_object` uses `filemd5(source)` as the object etag, so re-running Terraform after the source file changes will re-upload.
- `lifecycle_rules` is typed `any` — the caller is responsible for providing a shape the AWS provider accepts.
- The module attaches `var.tags` directly to the bucket. It does not synthesize any EPIC tags itself; callers are expected to pass `module.tags.tags` from `epic-pipeline-module-aws-tags`.
