# EPIC AWS Static Web Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-static-web  
**Module Type:** Tier 1 – Composed “Super” Infrastructure Module  
**Last Updated:** 2025-12-17

---

## Overview

This repository provides the **AWS Static Web “Super” Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module composes multiple **Tier 0 and Tier 1 foundational modules** into a **single, application-consumable unit** for deploying secure, enterprise-compliant static websites on AWS.

The module is designed to be:
- **Safe for direct use by application teams**
- **Secure-by-default**
- **Composable, opinionated, and EPIC-aligned**
- **Abstracted from AWS and Terraform complexity**

Application teams do **not** need to understand S3, CloudFront, IAM, or CodePipeline to use this module.

---

## What This Module Creates

This module provisions and configures the following AWS components:

- **S3 Bucket (private, encrypted, optional versioning)**
  - Hosts static web assets
  - Blocks public access
  - Supports optional access logging and lifecycle rules

- **CloudFront Distribution**
  - Secure global content delivery
  - Origin Access Control (OAC) enforced
  - Optional custom domain aliases and ACM certificates
  - Restricted to the PG&E AWS Organization

- **CodePipeline Deployment Pipeline**
  - Deploys static site assets to S3
  - Supports cache-control headers and content-type overrides

- **Enterprise Tagging**
  - Injected via the EPIC AWS Tags module
  - Enforces PG&E compliance, ownership, and classification standards

---

## Module Composition

This is a **Tier 1 Super Module** composed of the following EPIC modules:

- `epic-pipeline-module-aws-tags`
- `epic-pipeline-module-aws-s3` (Tier 0)
- `epic-pipeline-module-aws-cloudfront` (Tier 1)
- `epic-pipeline-module-aws-deploy-static-site`

All provider aliasing, regional requirements, and inter-module wiring are handled internally.

---

## Intended Usage

This module **may be used directly** by application teams via EPIC `resources.yml`.

Typical use cases include:
- Public or internal static websites
- Documentation portals
- UI-only applications (Angular, React, Vue, plain HTML)
- Frontends backed by APIs hosted elsewhere

---

## EPIC Usage (resources.yml)

Example usage within an EPIC-enabled application repository:

```yaml
parameters:
  app_name: "example-static-site"
  environment: "dev"
  aws_region: "us-west-2"

modules:
  - name: static_web
    path: epic-pipeline-module-aws-static-web
    variables:
      # Required but auto-injected by EPIC (can be omitted)
      principal_orgid: ${principal_orgid}
      app_name: ${app_name}
      environment: ${environment}

      # Required
      appid: "2324"
      notify:
        - lanid1@pge.com
        - lanid2@pge.com
        - lanid3@pge.com
      owner:
        - LANID1
        - LANID2
        - LANID3
      order: 123456789

      # Overrides
      enable_versioning: true
      app_path: "/"
```

---

## Required Inputs

| Name | Description |
|-----|-------------|
| `app_name` | Application name used for resource naming |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `appid` | AMPS application ID |
| `notify` | Notification email list |
| `owner` | List of three system owners |
| `order` | Financial order number |
| `principal_orgid` | AWS Organization ID |

---

## Optional Inputs

| Name | Description |
|-----|-------------|
| `custom_bucket_name` | Override default S3 bucket name |
| `enable_versioning` | Enable S3 versioning |
| `force_destroy` | Allow bucket deletion with objects |
| `enable_access_logging` | Enable S3 access logging |
| `lifecycle_rules` | S3 lifecycle configuration |
| `price_class` | CloudFront price class |
| `custom_domain_aliases` | Custom CloudFront domain names |
| `custom_acm_certificate_arn` | ACM cert ARN (us-east-1) |
| `app_path` | Path to static site assets |
| `cache_control` | Cache-Control header for uploads |
| `content_type_overrides` | MIME type overrides |

---

## Outputs

| Name | Description |
|-----|-------------|
| `bucket_name` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |
| `bucket_domain_name` | S3 domain name |
| `bucket_regional_domain_name` | Regional S3 domain |
| `cloudfront_distribution_id` | CloudFront distribution ID |
| `cloudfront_domain_name` | CloudFront domain name |

---

## Security & Compliance

This module enforces PG&E enterprise standards:

- No public S3 access
- Encryption at rest
- Secure CloudFront origin access
- Organization-based access controls
- Mandatory tagging and ownership metadata

All security decisions are centralized and maintained by the EPIC platform team.

---

## Module Tiering

| Tier | Description |
|-----|-------------|
| Tier 0 | Foundational, low-level infrastructure modules |
| Tier 1 | Composed infrastructure modules |
| **Tier 1 (Super)** | **Application-facing composed modules** |

This module is classified as **Tier 1 – Super Module**.

---

## Support & Ownership

This module is maintained by:

**PG&E Enterprise Cloud & DevSecOps**

Questions, enhancements, and fixes should be routed through the EPIC platform team.

