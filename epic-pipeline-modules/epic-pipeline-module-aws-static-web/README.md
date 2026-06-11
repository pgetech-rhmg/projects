# EPIC AWS Static Web Module

## Overview

This module provisions a complete AWS static website hosting stack — S3 origin, CloudFront distribution, deployment pipeline, and standardized tags — as a single composition.

It is a higher-level module that wraps four EPIC building blocks:

- `epic-pipeline-module-aws-tags` — standardized resource tagging
- `epic-pipeline-module-aws-s3` — private S3 bucket configured as a CloudFront origin
- `epic-pipeline-module-aws-cloudfront` — CloudFront distribution with OAC to the S3 bucket
- `epic-pipeline-module-aws-deploy-static-site` — CodePipeline-based static site deployment

Use this module when its composed defaults fit the workload. For SPAs requiring custom WAF, certificates, or Route 53 records, compose the underlying modules directly instead.

The module is consumed by application repositories that conform to the EPIC contract via `.pipeline/epic.json`.

---

## Resources

The module composes the following child modules, which in turn create:

- S3 bucket (private, with public access block, optional versioning, optional access logging, optional lifecycle rules, optional KMS encryption)
- CloudFront distribution with Origin Access Control (OAC) to the S3 bucket
- CloudFront cache and origin request policies
- CodePipeline and supporting resources for static site deployment
- Standardized PG&E governance tags applied across resources

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `principal_orgid` | `string` | AWS Organization ID used to scope CloudFront/S3 access policies. |
| `aws_account_id` | `string` | AWS account ID for tag generation and naming. |
| `app_name` | `string` | Application name, used in resource naming. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `appid` | `number` | AMPS APP ID in the format `APP-####`. |
| `notify` | `list(string)` | Notification recipients (email addresses or distribution lists) for failures and maintenance. |
| `owner` | `list(string)` | Three system owners as defined by AMPS (Director, Client Owner, IT Lead) — LANIDs. |
| `order` | `number` | AMPS order number (7–9 digits) used as a tag. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `dataclassification` | `string` | `"Internal"` | One of `Public`, `Internal`, `Confidential`, `Restricted`, `Privileged`, `Confidential-BCSI`, `Restricted-BCSI`. |
| `compliance` | `list(string)` | `["None"]` | Compliance scope. Values: `SOX`, `HIPAA`, `CCPA`, `BCSI`, `None`. |
| `cris` | `string` | `"Low"` | Cyber Risk Impact Score: `High`, `Medium`, `Low`. |
| `custom_bucket_name` | `string` | `null` | Globally-unique S3 bucket name override. |
| `force_destroy` | `bool` | `false` | Allow Terraform to delete the bucket even if it contains objects. |
| `object_ownership` | `string` | `"BucketOwnerEnforced"` | One of `BucketOwnerEnforced`, `BucketOwnerPreferred`, `ObjectWriter`. |
| `enable_public_access_block` | `bool` | `true` | Enforce S3 public access block at the bucket level. |
| `enable_versioning` | `bool` | `false` | Enable S3 versioning. |
| `sse_algorithm` | `string` | `"AES256"` | Server-side encryption algorithm: `AES256` or `aws:kms`. |
| `kms_key_arn` | `string` | `null` | KMS key ARN; required when `sse_algorithm = "aws:kms"`. |
| `enable_access_logging` | `bool` | `false` | Enable S3 server access logging. |
| `access_log_bucket` | `string` | `null` | Target bucket for access logs (required if logging is enabled). |
| `access_log_prefix` | `string` | `null` | Prefix applied to access log objects. |
| `lifecycle_rules` | `any` | `[]` | List of S3 lifecycle rule objects. Supports `id`, `enabled`, `prefix`, `filter`, `transitions`, `expiration`, `noncurrent_version_expiration`. |
| `bucket_policy_json` | `string` | `null` | Optional raw JSON bucket policy. |
| `price_class` | `string` | `"PriceClass_100"` | CloudFront price class: `PriceClass_All`, `PriceClass_100`, `PriceClass_200`. |
| `custom_domain_aliases` | `list(string)` | `[]` | Custom domain aliases for the CloudFront distribution. |
| `custom_acm_certificate_arn` | `string` | `null` | ACM certificate ARN (must be in `us-east-1`). |
| `app_path` | `string` | `"/"` | Relative path under the build artifact containing static site files. |
| `cache_control` | `string` | `null` | Optional `Cache-Control` header applied to uploaded objects. |
| `content_type_overrides` | `map(string)` | `{}` | File extension to MIME type overrides for uploads. |

---

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | S3 bucket name. |
| `bucket_arn` | S3 bucket ARN. |
| `bucket_domain_name` | S3 bucket domain name. |
| `bucket_regional_domain_name` | S3 bucket regional domain name. |
| `distribution_id` | CloudFront distribution ID. |
| `distribution_arn` | CloudFront distribution ARN. |
| `distribution_domain_name` | CloudFront distribution domain name. |

---

## Usage in a Terraform project

The module requires two configured AWS provider aliases:

- `aws.deploy` — the target deployment account/region
- `aws.us_east_1` — `us-east-1`, required for CloudFront-scoped resources (ACM)

```hcl
provider "aws" {
  alias  = "deploy"
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-static-web.git?ref=main"

  providers = {
    aws           = aws.deploy
    aws.us_east_1 = aws.us_east_1
  }

  principal_orgid = var.principal_orgid
  aws_account_id  = var.aws_account_id
  app_name        = var.app_name
  environment     = var.environment

  appid  = var.appid
  notify = var.notify
  owner  = var.owner
  order  = var.order

  dataclassification = "Internal"
  compliance         = ["None"]
  cris               = "Low"

  enable_versioning = true
  price_class       = "PriceClass_100"

  custom_domain_aliases      = var.custom_domain_aliases
  custom_acm_certificate_arn = var.custom_acm_certificate_arn

  app_path = "/dist"
}
```

---

## Usage from another module

When called from a parent module, declare the provider aliases in the parent's `versions.tf` and pass them through explicitly:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.90"
      configuration_aliases = [aws.deploy, aws.us_east_1]
    }
  }
}

module "static_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-static-web.git?ref=main"

  providers = {
    aws           = aws.deploy
    aws.us_east_1 = aws.us_east_1
  }

  # ... inputs
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS provider | `~> 5.90` |

The module declares `configuration_aliases` for `aws.deploy` and `aws.us_east_1`; both must be supplied by the consuming configuration.

---

## Notes

- ACM certificates passed via `custom_acm_certificate_arn` must reside in `us-east-1` because CloudFront only consumes certificates from that region.
- `kms_key_arn` is only honored when `sse_algorithm = "aws:kms"`.
- This module does not create Route 53 records or WAF resources. If the application requires DNS aliases, a hosted zone record, or a WAFv2 ACL, compose those modules directly alongside this one.
