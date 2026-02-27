# EPIC AWS Deploy Static Site Module

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-deploy-static-site  
**Module Type:** Tier 2 – Workload / Application Deployment Module  
**Last Updated:** 2025-12-17

---

## Overview

This repository provides the **AWS static website deployment Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is **purpose-built for deploying static website assets** (HTML, CSS, JavaScript, images, etc.) to an **existing S3 bucket**.  
It is intentionally **narrow in scope**, **pipeline-driven**, and **safe to re-run**.

This module does **not** create infrastructure.  
It **consumes** foundational infrastructure created by other EPIC modules, such as:

- `pge-pipeline-module-aws-s3`
- `pge-pipeline-module-aws-cloudfront`

---

## Design Principles

### Single Responsibility

This module performs **one job only**:

> Deterministically upload static website files to S3.

It does **not**:
- Build applications
- Run npm / Angular / .NET builds
- Zip or package artifacts
- Modify bucket configuration
- Manage CloudFront

All build steps occur **outside Terraform**, typically in the EPIC pipeline.

---

### Static-Site Specific (By Design)

This module is **explicitly static-site focused**.

Other delivery models (Angular, .NET, APIs, Lambdas, containers) are handled by **separate deploy modules** to avoid:
- Conditional logic
- Feature flags
- Polymorphic Terraform modules

This ensures clarity, scalability, and long-term maintainability.

---

### EPIC Workspace Compatibility

The module resolves website assets using the EPIC workspace layout:

```hcl
${path.root}/${app_name}/${app_path}
```

This allows:
- Multi-app repositories
- Environment isolation
- Pipeline-driven builds
- Zero hardcoded paths

---

## What This Module Deploys

- All files under the resolved website directory
- Uploaded as individual `aws_s3_object` resources
- Changes detected via file `etag` (MD5)
- Content-Type automatically inferred by file extension
- Optional `Cache-Control` header support

---

## What This Module Does NOT Do

- ❌ Create or configure S3 buckets  
- ❌ Enable static website hosting  
- ❌ Configure CloudFront  
- ❌ Invalidate CloudFront caches  
- ❌ Build or transpile code  

Those responsibilities belong to other EPIC modules or pipeline steps.

---

## Required Inputs

| Variable Name | Description |
|--------------|-------------|
| `app_name` | Application name used to resolve workspace path |
| `app_path` | Relative path to static site assets under the app folder |
| `bucket_name` | Target S3 bucket name |

---

## Optional Inputs

| Variable Name | Description |
|--------------|-------------|
| `cache_control` | Cache-Control header applied to uploaded objects |
| `content_type_overrides` | Map of file extension → MIME type overrides |

---

## Example EPIC Usage (resources.yml)

```yaml
modules:
  - name: deploy-static-site
    path: epic-pipeline-module-aws-deploy-static-site
    variables:
       # Required but auto-injected by EPIC (can be omitted)
      app_name: "${app_name}"
      bucket_name: "${bucket_name}"

      # Overrides
      app_path: "/"
      cache_control: "max-age=3600"
```

---

## Outputs

| Output Name | Description |
|------------|-------------|
| `deployed_bucket` | Name of the S3 bucket receiving website assets |
| `file_count` | Number of files deployed |

---

## Intended Consumers

This module is designed for:
- Static HTML websites
- Angular / React / Vue build outputs
- Documentation sites
- Lightweight front-end applications

For other workloads, use the appropriate EPIC deploy module.

---

## EPIC Module Tiering

| Tier | Responsibility |
|-----|---------------|
| Tier 0 | Foundational infrastructure (S3, IAM, KMS) |
| Tier 1 | Platform services (CloudFront, ALB, RDS) |
| Tier 2 | Application deployment (this module) |

---

## Summary

This module completes the **static website delivery path** in EPIC:

Infrastructure:
- `aws-s3`
- `aws-cloudfront`

Deployment:
- `aws-deploy-static-site`

Clear boundaries.  
No hidden logic.  
Pipeline-first by design.

---

