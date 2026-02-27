# EPIC AWS Tags Module

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-tags  
**Module Type:** Tier 0 – Foundational Governance Module  
**Last Updated:** 2025-12-17

---

## Overview

This repository provides the **AWS tags Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is a **foundational governance building block** that standardizes and enforces **required enterprise tags** across all AWS resources deployed through EPIC.

It does **not** create AWS resources.  
It exists solely to **centralize, normalize, and consistently apply tagging logic** across all modules.

---

## Design Principles

### Single Source of Truth for Tags

All required enterprise tags are defined **once**, in one place.

Downstream modules:
- Consume the tag map
- Apply it directly to AWS resources
- Never reimplement tagging logic

This prevents:
- Drift
- Misspellings
- Missing tags
- Inconsistent formats across teams

---

### Tier 0 Governance Responsibility

This module is classified as **Tier 0** because:
- It applies to **all resources**
- It enforces **enterprise policy**
- It has no application context
- It is stable, long-lived, and reused everywhere

This module is expected to be consumed by:
- Tier 0 modules (S3, IAM, KMS)
- Tier 1 modules (CloudFront, ALB)
- Tier 2 modules (application deploy modules)

---

## What This Module Produces

This module produces a **single normalized tag map** containing required enterprise metadata, including (but not limited to):

- Application identification
- Environment classification
- Data classification
- Compliance indicators
- Ownership and billing metadata
- Notification routing

All formatting and normalization is handled internally.

---

## Core Logic

The module constructs the tag map as follows:

```hcl
locals {
  tags = {
    AppID              = "APP-${var.appid}"
    Environment        = var.environment
    DataClassification = var.dataclassification
    CRIS               = var.cris
    Notify             = join("_", var.notify)
    Owner              = join("_", var.owner)
    Compliance         = join("_", var.compliance)
    Order              = var.order
  }
}
```

This ensures:
- Predictable tag keys
- Consistent value formatting
- No duplicated logic in consuming modules

---

## Required Inputs

| Variable Name | Description |
|--------------|-------------|
| `environment` | Deployment environment (dev, test, qa, prod) |
| `appid` | Application identifier (numeric portion only) |
| `notify` | List of notification identifiers |
| `owner` | List of owner identifiers |
| `order` | Internal order or cost tracking reference |

### Optional Inputs

| Name | Description | Default |
|----|----|----|
| `dataclassification` | Data classification level | `Internal` |
| `compliance` | List of compliance indicators | ["None"] |
| `cris` | Criticality rating | `Low` |

---

## Outputs

| Output Name | Description |
|------------|-------------|
| `tags` | Normalized map of required enterprise tags |

---

## Example EPIC Usage (resources.yml)

```yaml
modules:
  - name: tags
    path: epic-pipeline-module-aws-tags
    variables:
      # Required but auto-injected by EPIC (can be omitted)
      environment: ${environment}

      # Required
      appid: "2324"
      notify:
        - abcd@pge.com
        - efgh@pge.com
        - wxyz@pge.com
      owner:
        - abcd
        - efgh
        - wxyz
      order: 123456789

      # Overrides
      dataclassification: "Restricted"
```

---

## Intended Usage Pattern

This module is intended to be:
- Declared **once** per EPIC deployment
- Passed into all other modules as a `tags` input
- Used consistently across all AWS resources

Example consumption pattern:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  tags   = module.tags.tags
}
```

---

## What This Module Does NOT Do

- ❌ Create AWS resources  
- ❌ Apply tags automatically  
- ❌ Validate business rules  
- ❌ Enforce policies directly  

Those responsibilities belong to consuming modules and platform governance controls.

---

## EPIC Module Tiering

| Tier | Responsibility |
|-----|---------------|
| Tier 0 | Foundational governance and infrastructure |
| Tier 1 | Platform and edge services |
| Tier 2 | Application deployment |

This module is a **Tier 0 governance dependency** for all other EPIC modules.

---

## Summary

This module exists to make tagging:

- Centralized
- Predictable
- Enforced by design
- Invisible to application teams

By separating tagging into its own Tier 0 module, EPIC ensures that **every resource is compliant by default**, without duplicating logic or relying on developer discipline.

---

