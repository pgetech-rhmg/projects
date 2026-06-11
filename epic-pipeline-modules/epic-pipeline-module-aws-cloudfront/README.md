# epic-pipeline-module-aws-cloudfront

Provisions a CloudFront distribution in front of an S3 origin for SPA hosting. Creates the OAC, origin/response policies, the distribution, and replaces the backing bucket policy with one that allows CloudFront read access while preserving the CCOE-TFE org-wide and TLS-only deny guardrails.

---

## Resources Created

- `aws_cloudfront_origin_access_control.oac` — SigV4 OAC for the S3 origin
- `aws_cloudfront_origin_request_policy.spa_origin_policy` — SPA-friendly origin request policy (forwards `Origin` and CORS preflight headers, no cookies, no query strings)
- `aws_cloudfront_response_headers_policy.cors` — CORS response headers policy driven by `cors_allowed_origins`
- `aws_cloudfront_distribution.cdn` — The distribution itself: `index.html` default root, HTTPS redirect, AWS-managed `CachingOptimized` cache policy, 403/404 rewrites to `200 /index.html` for SPA routing, optional WAF and ACM custom-domain wiring
- `aws_s3_bucket_policy.cloudfront_access` — Bucket policy on `var.bucket_name` granting CloudFront read access and enforcing `aws:PrincipalOrgID` and `aws:SecureTransport` denies

---

## Inputs

### Required

| Name | Type | Description |
|---|---|---|
| `app_name` | `string` | Application name used in CloudFront resource names. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `principal_orgid` | `string` | AWS Organization ID enforced in the bucket policy `Deny` (CCOE-TFE guardrail). |
| `bucket_name` | `string` | Name of the S3 bucket backing CloudFront. |
| `bucket_arn` | `string` | ARN of the S3 bucket backing CloudFront. |
| `bucket_regional_domain_name` | `string` | Regional domain name of the S3 bucket (not the website endpoint). |
| `tags` | `map(string)` | Common tags applied to taggable resources. |

### Optional

| Name | Type | Default | Description |
|---|---|---|---|
| `price_class` | `string` | `"PriceClass_100"` | One of `PriceClass_All`, `PriceClass_100`, `PriceClass_200`. |
| `custom_domain_aliases` | `list(string)` | `[]` | CNAME aliases on the distribution. Requires `custom_acm_certificate_arn`. |
| `custom_acm_certificate_arn` | `string` | `null` | ACM cert ARN in `us-east-1`. When set, distribution uses SNI + `TLSv1.2_2021`; when null, the CloudFront default cert is used. |
| `cors_allowed_origins` | `list(string)` | `["*"]` | Origins allowed by the response headers CORS policy. |
| `web_acl_id` | `string` | `null` | WAFv2 WebACL ARN in `us-east-1` (scope `CLOUDFRONT`) to associate with the distribution. |

---

## Outputs

| Name | Description |
|---|---|
| `distribution_id` | CloudFront distribution ID. |
| `distribution_arn` | CloudFront distribution ARN. |
| `distribution_domain_name` | CloudFront distribution domain name (e.g. `dxxxx.cloudfront.net`). |

---

## Provider Requirements

Defined in `versions.tf`:

- `terraform >= 1.5.0`
- `hashicorp/aws ~> 5.90` with a configuration alias for `aws.us_east_1`

CloudFront itself is global, but ACM certs and WAFv2 WebACLs attached to a CloudFront distribution must live in `us-east-1`. This module declares an `aws.us_east_1` configuration alias so the consumer can pass through a regional provider for those upstream resources. The consumer must supply both providers explicitly:

```hcl
providers = {
  aws           = aws
  aws.us_east_1 = aws.us_east_1
}
```

---

## Usage from a Terraform Project (`.infra/`)

Direct consumption from an EPIC application's `.infra/main.tf`. This is the canonical pattern from `epic-web/.infra/main.tf`:

```hcl
module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  app_name                    = "${var.app_name}-web"
  environment                 = var.environment
  principal_orgid             = var.principal_orgid
  bucket_name                 = module.s3_web.bucket_name
  bucket_arn                  = module.s3_web.bucket_arn
  bucket_regional_domain_name = module.s3_web.bucket_regional_domain_name
  price_class                 = var.price_class
  custom_domain_aliases       = var.custom_domain_aliases
  custom_acm_certificate_arn  = module.acm_web.certificate_arn
  cors_allowed_origins        = var.cors_allowed_origins
  web_acl_id                  = aws_wafv2_web_acl.web.arn

  tags = merge(module.tags.tags, { Name = "pge-epic-${var.app_name}-web-${var.environment}-cloudfront" })
}
```

The S3 origin is provisioned by `epic-pipeline-module-aws-s3`, the ACM cert by `epic-pipeline-module-aws-certificate` (with `aws.us_east_1`), and the WAFv2 WebACL is created in `us-east-1` directly in the project. CloudFront then composes them.

The application repo's `.pipeline/epic.json` is what selects this `.infra/` directory and triggers `terraform apply` through the EPIC engine; the module itself has no awareness of `epic.json`.

---

## Usage from Another Module (Composition)

When wrapping `cloudfront` inside a higher-level module (e.g. a "static SPA" composite module), the wrapper must also declare the `aws.us_east_1` configuration alias and forward both providers:

```hcl
# wrapper module's versions.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.90"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# wrapper module's main.tf
module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  app_name                    = var.app_name
  environment                 = var.environment
  principal_orgid             = var.principal_orgid
  bucket_name                 = var.bucket_name
  bucket_arn                  = var.bucket_arn
  bucket_regional_domain_name = var.bucket_regional_domain_name
  custom_acm_certificate_arn  = var.custom_acm_certificate_arn
  custom_domain_aliases       = var.custom_domain_aliases
  web_acl_id                  = var.web_acl_id
  cors_allowed_origins        = var.cors_allowed_origins
  tags                        = var.tags
}
```

The root module must instantiate two AWS providers (one default, one aliased to `us-east-1`) and pass both into the wrapper.

---

## Notes

- The module owns the bucket policy on `bucket_name`. Any other writer of that bucket policy will conflict — keep policy authorship here so the CloudFront read-allow and the CCOE-TFE `PrincipalOrgID` / `SecureTransport` denies stay in sync.
- 403 and 404 responses from the origin are rewritten to `200 /index.html` to support client-side routing in SPAs.
- The default cache policy is the AWS-managed `CachingOptimized` (`658327ea-f89d-4fab-a63d-7e88639e58f6`).
- Setting `custom_domain_aliases` without a matching `custom_acm_certificate_arn` will fail at apply — CloudFront requires a cert in `us-east-1` for any alias.
- `web_acl_id` expects a WAFv2 WebACL ARN with `scope = CLOUDFRONT`, which means it must have been created against the `aws.us_east_1` provider.
