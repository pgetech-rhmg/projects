# EPIC AWS CloudFront Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-cloudfront  
**Module Type:** Tier 1 – Platform / Edge Infrastructure Module  
**Last Updated:** 2025-12-17

---

## Overview

This repository provides the **foundational AWS CloudFront Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is intentionally **low-level, edge-focused, and policy-agnostic**.  
It is designed to act as a **Tier 0 building block** upon which higher-level, purpose-specific delivery modules are built (for example: `s3-web`, `static-site`, `cdn-with-waf`).

While most application teams will consume CloudFront through higher-level EPIC modules, **this module may be used directly by advanced users** who understand CloudFront behavior, S3 origin access patterns, and TLS configuration.

---

## Design Principles

This module follows strict enterprise standards:

- Secure by default
- Origin Access Control (OAC) enforced
- No public S3 access
- No embedded org or ownership policies
- No application assumptions
- Optional ACM integration
- Explicit provider aliasing (`us-east-1`)
- Compatible with EPIC auto-wiring and orchestration

This ensures:
- Clear separation of responsibilities
- Safe composition with S3 and WAF modules
- Reusability across many delivery patterns
- Predictable edge behavior

---

## What This Module Is (and Is Not)

### ✅ This module **IS**
- A foundational CloudFront distribution implementation
- An edge delivery primitive
- A reusable Tier 0 building block
- Suitable for direct use by experienced Terraform users

### ❌ This module is **NOT**
- A website module
- An S3 module
- A WAF module
- A DNS module
- A place to embed org-wide security or ownership rules

---

## Resources Created

This module creates the following AWS resources:

- `aws_cloudfront_distribution`
- `aws_cloudfront_origin_access_control`
- `aws_s3_bucket_policy` (CloudFront read access only)

It also consumes **AWS-managed CloudFront policies**:

- Managed cache policy (`Managed-CachingOptimized`)
- Managed origin request policy (`Managed-CORS-S3Origin`)

---

## Security Defaults

The following security controls are enforced automatically:

- S3 origin access via **Origin Access Control (OAC)**
- No public S3 access
- HTTPS enforced at the edge
- Modern AWS-managed cache policies

⚠️ **Important:**  
This module does **not** enforce:

- Org-based S3 access restrictions
- TLS-only bucket policies
- Ownership or compliance tagging

Those concerns belong to the **S3 Tier 0 module** or higher-level composed modules.

---

## Inputs

### Required Inputs

| Name | Description |
|----|----|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `bucket_name` | Name of the S3 origin bucket |
| `bucket_arn` | ARN of the S3 origin bucket |
| `bucket_regional_domain_name` | Regional domain name of the S3 bucket |
| `tags` | Resource tags (provided by module.tags.tags) |

### Optional Inputs

| Name | Description | Default |
|----|----|----|
| `price_class` | CloudFront price class | `PriceClass_100` |
| `custom_domain_aliases` | Custom domain aliases | `[]` |
| `custom_acm_certificate_arn` | ACM cert ARN (us-east-1) | `null` |

---

## Outputs

| Name | Description |
|----|----|
| `distribution_id` | CloudFront distribution ID |
| `distribution_arn` | CloudFront distribution ARN |
| `distribution_domain_name` | CloudFront domain name |

---

## Example Usage (Direct Terraform)

> **For advanced users or EPIC module authors**

This example creates a **secure CloudFront distribution** in front of an existing private S3 bucket.

```hcl
module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git"

  app_name    = "example-app"
  environment = "dev"

  bucket_name                 = module.s3.bucket_name
  bucket_arn                  = module.s3.bucket_arn
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name

  tags = {
    delivery = "cdn"
    owner    = "team-x"
  }
}
```

---

## EPIC Usage (resources.yml)

This module **may be used directly** in EPIC when explicit control of CloudFront behavior is required.

```yaml
modules:
  - name: cloudfront
    path: epic-pipeline-module-aws-cloudfront
    variables:
      # Required but auto-injected by EPIC (can be omitted)
      principal_orgid: ${principal_orgid}
      app_name: ${app_name}
      environment: ${environment}
      tags: module.tags.tags
      bucket_name: module.s3.bucket_name
      bucket_arn: module.s3.bucket_arn
      bucket_regional_domain_name: module.s3.bucket_regional_domain_name

      # Overrides
      price_class: "PriceClass_200"
```

In most cases, EPIC applications will instead use higher-level "super" modules such as:

- `pge-pipeline-module-aws-s3-web`
- `pge-pipeline-module-aws-static-site`
- `pge-pipeline-module-aws-cdn-with-waf`

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "cdn" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git"

  app_name    = var.app_name
  environment = var.environment

  bucket_name                 = module.bucket.bucket_name
  bucket_arn                  = module.bucket.bucket_arn
  bucket_regional_domain_name = module.bucket.bucket_regional_domain_name
}
```

Access control and compliance must be layered **outside** this module.

---

## Naming Conventions

This module does not enforce naming directly.

Typical EPIC naming patterns resolve to:

```text
<prefix>-<app>-<environment>-<purpose>
```

Example:

```text
pge-example-dev-cdn
```

Final naming decisions are owned by the consuming module or EPIC pipeline.

---

## Terraform Compatibility

- Terraform >= 1.5
- AWS Provider >= 5.x

---

## Why This Module Exists

This module exists to:

- Eliminate copy-paste CloudFront implementations
- Standardize secure edge delivery
- Enforce OAC-based S3 access
- Enable safe, repeatable CDN composition
- Scale consistently across the enterprise

It is a **foundation**, not a feature.

---

## Ownership

Maintained by:  
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:
- Website hosting
- Custom domains + DNS
- WAF protection
- Logging and monitoring
- Org or cross-account security controls

👉 Use or create a **higher-level EPIC module** that composes this Tier 0 module with the appropriate policies and integrations.

This module should remain **clean, minimal, and edge-focused**.

