# EPIC Azure Tags Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-tags
**Module Type:** Tier 0 -- Foundational Governance Module
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **Azure tags Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is the **Azure equivalent** of `epic-pipeline-module-aws-tags`. Where the AWS module uses `AWSAccountID`, this module uses `SubscriptionID` to identify the Azure subscription associated with the resource.

This module is a **foundational governance building block** that standardizes and enforces **required enterprise tags** across all Azure resources deployed through EPIC.

It does **not** create Azure resources.
It exists solely to **centralize, normalize, and consistently apply tagging logic** across all modules.

---

## Design Principles

### Single Source of Truth for Tags

All required enterprise tags are defined **once**, in one place.

Downstream modules:
- Consume the tag map
- Apply it directly to Azure resources
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
- Tier 0 modules (Storage Accounts, Key Vaults, Managed Identities)
- Tier 1 modules (App Gateway, Front Door)
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
    ManagedBy          = "EPIC"
    Team               = "CCoE"
    SubscriptionID     = var.subscription_id
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
| `subscription_id` | Azure Subscription ID for the target subscription |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `appid` | Application identifier (numeric portion only) |
| `notify` | List of notification email addresses |
| `owner` | List of exactly 3 owner identifiers |
| `order` | Internal order or cost tracking reference (7-9 digits) |

### Optional Inputs

| Name | Description | Default |
|----|----|----|
| `dataclassification` | Data classification level | `Internal` |
| `compliance` | List of compliance indicators | `["None"]` |
| `cris` | Criticality rating | `Low` |

---

## Outputs

| Output Name | Description |
|------------|-------------|
| `tags` | Standard EPIC tag map for Azure resources |

---

## Example EPIC Usage (resources.yml)

```yaml
modules:
  - name: tags
    path: epic-pipeline-module-azure-tags
    variables:
      # Required but auto-injected by EPIC (can be omitted)
      environment: ${environment}

      # Required
      subscription_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
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
- Used consistently across all Azure resources

Example consumption pattern:

```hcl
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tags.tags
}
```

---

## What This Module Does NOT Do

- Does not create Azure resources
- Does not apply tags automatically
- Does not validate business rules
- Does not enforce policies directly

Those responsibilities belong to consuming modules and platform governance controls.

---

## EPIC Module Tiering

| Tier | Responsibility |
|-----|---------------|
| Tier 0 | Foundational governance and infrastructure |
| Tier 1 | Platform and edge services |
| Tier 2 | Application deployment |

This module is a **Tier 0 governance dependency** for all other EPIC Azure modules.

---

## Summary

This module exists to make tagging:

- Centralized
- Predictable
- Enforced by design
- Invisible to application teams

By separating tagging into its own Tier 0 module, EPIC ensures that **every resource is compliant by default**, without duplicating logic or relying on developer discipline.

---
