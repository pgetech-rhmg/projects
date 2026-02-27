# EPIC AWS S3 Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-s3  
**Module Type:** Tier 0 – Foundational Infrastructure Module  
**Last Updated:** 2025-12-17

---

## Overview

This repository provides the **foundational AWS S3 Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is intentionally **low-level, secure-by-default, and policy-agnostic**. It is designed to act as a **Tier 0 building block** upon which higher-level, purpose-specific S3 modules are built (for example: `s3-web`, `s3-artifacts`, `s3-logs`).

While most application teams will consume S3 through higher-level EPIC modules, **this module may be used directly by advanced users** who understand and explicitly manage S3 access policies.

---

## Design Principles

This module follows strict enterprise standards:

- Secure by default
- No public access
- Encryption enabled
- Versioning configurable
- Explicit ownership and tagging
- **No embedded access policy logic**
- No application or consumer assumptions
- Compatible with EPIC auto-wiring and orchestration

This ensures:
- Predictable security posture
- Clear separation of concerns
- Easier policy composition
- Safe reuse across many use cases

---

## What This Module Is (and Is Not)

### ✅ This module **IS**
- A foundational S3 bucket implementation
- A secure storage primitive
- A reusable Tier 0 building block
- Suitable for direct use by experienced Terraform users

### ❌ This module is **NOT**
- A website module
- A CloudFront module
- A logging or artifacts module
- A place to embed access or org-specific policy rules

---

## Resources Created

This module creates the following AWS resources:

- `aws_s3_bucket`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_ownership_controls`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_versioning`
- `aws_s3_bucket_lifecycle_configuration`
- Optional: `aws_s3_bucket_logging`
- Optional: `aws_s3_bucket_policy` (only when provided by the caller)

---

## Security Defaults

The following security controls are enforced automatically:

- Public access fully blocked (ACLs + public policies)
- Bucket owner enforced (ACLs disabled)
- Server-side encryption enabled
- Versioning supported and recommended

⚠️ **Important:**  
This module does **not** embed any access policies by default.

If no bucket policy is supplied:
- The bucket is **private**
- No services or users can read objects
- This is intentional and secure-by-default

Access must be granted explicitly by the caller.

---

## Inputs

### Required Inputs

| Name | Description |
|----|----|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags (provided by module.tags.tags) |

### Optional Inputs

| Name | Description | Default |
|----|----|----|
| `custom_bucket_name` | Explicit bucket name override | `null` |
| `enable_versioning` | Enable object versioning | `true` |
| `enable_public_access_block` | Enforce public access block | `true` |
| `object_ownership` | Object ownership mode | `BucketOwnerEnforced` |
| `bucket_policy_json` | Full S3 bucket policy JSON | `null` |
| `lifecycle_rules` | Lifecycle configuration rules | `[]` |
| `enable_access_logging` | Enable access logging | `false` |
| `access_log_bucket` | Target bucket for access logs | `null` |
| `access_log_prefix` | Log prefix | `null` |

---

## Outputs

| Name | Description |
|----|----|
| `bucket_name` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |
| `bucket_domain_name` | S3 domain name |
| `bucket_regional_domain_name` | Regional S3 domain name |

---

## Example Usage (Direct Terraform)

> **For advanced users or EPIC module authors**

This example creates a **private, encrypted S3 bucket** with no access granted.

```hcl
module "s3" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git"

  app_name    = "example-app"
  environment = "dev"

  enable_versioning = true

  tags = {
    data_classification = "Restricted"
    owner               = "team-x"
  }
}
```

To allow access (CloudFront, org-only, cross-account, etc.), attach a **separately composed bucket policy** via `bucket_policy_json`.

---

## EPIC Usage (resources.yml)

This module **may be used directly** in EPIC when full control is required.

```yaml
modules:
  - name: s3
    path: epic-pipeline-module-aws-s3
    variables:
       # Required but auto-injected by EPIC (can be omitted)
      app_name: ${app_name}
      environment: ${environment}

      # Overrides
      enable_versioning: true

      tags: module.tags.tags
```

In most cases, EPIC applications will instead use higher-level "super" modules such as:

- `pge-pipeline-module-aws-s3-web`
- `pge-pipeline-module-aws-s3-artifacts`
- `pge-pipeline-module-aws-s3-logs`

These higher-level modules:
- Consume this Tier 0 module internally
- Compose and inject bucket policies
- Expose simplified, opinionated inputs
- Auto-wire outputs to downstream resources

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "bucket" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git"

  app_name    = var.app_name
  environment = var.environment

  enable_versioning = true
}
```

Access intent (CloudFront, org-only, etc.) must be layered **outside** this module.

---

## Naming Conventions

This module does not enforce naming directly.

Typical EPIC naming patterns resolve to:

```text
<prefix>-<app>-<environment>-<purpose>
```

Example:

```text
pge-example-dev-web
```

Final naming decisions are owned by the consuming module or EPIC pipeline.

---

## Terraform Compatibility

- Terraform >= 1.5
- AWS Provider >= 5.x

---

## Why This Module Exists

This module exists to:

- Eliminate copy-paste S3 implementations
- Centralize storage security primitives
- Enable safe policy composition
- Reduce unintended exposure
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
- CloudFront access
- Org or cross-account access
- Logging or artifacts behavior

👉 Use or create a **higher-level EPIC module** that composes this Tier 0 module and injects the appropriate access policies.

This module should remain **clean, minimal, and consumer-agnostic**.

