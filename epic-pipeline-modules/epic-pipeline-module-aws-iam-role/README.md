# EPIC AWS IAM Role Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-aws-iam-role  
**Module Type:** Tier 0 – Foundational Infrastructure Module  
**Last Updated:** 2025-12-18

---

## Overview

This repository provides the **foundational AWS IAM Role Terraform module** used by PG&E’s **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module is **one of the most critical security components in EPIC**.  
It must be **correct, consistent, and simple to consume**.

To achieve this, EPIC deliberately separates:

- **User intent** (what the role is for)
- **Enterprise policy** (how the role is implemented)
- **Terraform mechanics** (how AWS IAM works)

Most users will **never interact with IAM or Terraform concepts directly**.

---

## Core EPIC Principle (Read This First)

> **Application teams should never need to understand IAM, Terraform, or AWS trust policies.**

EPIC exists to abstract those details away while enforcing enterprise-grade security.

This module supports **three clearly defined usage levels**, ensuring simplicity by default and power only when explicitly needed.

---

## Usage Levels (Critical Concept)

| Level | Audience | Purpose |
|----|--------|--------|
| Level 1 | Application teams | Simple intent-based roles |
| Level 2 | Advanced users | Capability-based customization |
| Level 3 | Platform / Security | Full IAM control (escape hatch) |

Most users should **never go beyond Level 1**.

---

## Level 1 — Simple Intent-Based Roles (Default)

### Who this is for
- Application teams
- Developers
- Anyone who does not want to think about IAM

### What the user provides
Only **intent**, not implementation.

Example:

```yaml
modules:
  - name: iam_role
    path: epic-pipeline-module-aws-iam-role
    variables:
      role_name: "deploy"
      role_type: terraform
```

### What EPIC does automatically
Based on `role_type`, EPIC:
- Generates the trust policy
- Selects the correct authentication method (OIDC, service principal, etc.)
- Attaches enterprise-approved policies
- Applies required tags
- Ensures least-privilege defaults

### Common `role_type` values

| role_type | Intended Use |
|---------|--------------|
| terraform | EPIC Terraform execution roles |
| cicd | CI/CD pipelines |
| lambda | Lambda execution |
| ecs | ECS task execution |
| readonly | Read-only access roles |

Users **do not** need to know how these are implemented.

---

## Level 2 — Advanced Capability-Based Roles

### Who this is for
- Power users
- Platform-adjacent teams
- Advanced application scenarios

Still **no IAM syntax required**.

### Example

```yaml
modules:
  - name: iam_role
    path: epic-pipeline-module-aws-iam-role
    variables:
      role_name: "app-runtime"
      role_type: lambda
      capabilities:
        - s3_read
        - logs_write
```

### What EPIC does
- Maps capabilities to approved policy sets
- Combines multiple permissions safely
- Enforces policy boundaries
- Prevents over-privileged access

### Example capability catalog (enterprise-defined)

| Capability | Description |
|----------|-------------|
| s3_read | Read-only S3 access |
| s3_write | Write access to specific buckets |
| logs_write | CloudWatch Logs write access |
| secrets_read | Read access to Secrets Manager |
| dynamodb_rw | Read/write DynamoDB |

Capabilities are **named, documented, and reviewed** by the platform team.

---

## Level 3 — Expert / Escape Hatch Mode

### Who this is for
- Platform engineers
- Security teams
- Rare edge cases

⚠️ **This level should be used sparingly and reviewed carefully.**

### Example

```yaml
modules:
  - name: iam_role
    path: epic-pipeline-module-aws-iam-role
    variables:
      role_name: "special-case"
      custom_trust: true
      trusted_principals:
        - type: oidc
          provider: ado
          subject: "repo:pgetech/legacy-app"
      policy_arns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
```

### Important notes
- IAM knowledge is required at this level
- EPIC still enforces tagging and naming standards
- This mode is typically restricted to approved repos

---

## What This Module Does

This module:
- Creates a single IAM role
- Applies a generated or user-defined trust policy
- Attaches managed and/or inline policies
- Enforces enterprise tagging standards

---

## What This Module Does NOT Do

This module intentionally does **not**:
- Define application-specific logic
- Hard-code permissions
- Embed environment branching
- Assume deployment tooling
- Create IAM users or access keys

Those responsibilities belong to EPIC orchestration or higher-tier modules.

---

## Inputs (Terraform-Level)

These inputs exist primarily for EPIC and advanced users.

| Name | Description |
|----|------------|
| role_name | IAM role name |
| trusted_principals | Trust relationships (advanced) |
| policy_arns | Managed policies to attach |
| inline_policies | Optional inline policies |
| tags | Resource tags |

Most users **will not supply these directly**.

---

## Outputs

| Name | Description |
|----|------------|
| role_name | IAM role name |
| role_arn | IAM role ARN |

---

## Security Model

IAM roles created through EPIC are:

- Explicitly trusted
- Least-privileged by default
- Centrally auditable
- Consistent across accounts
- Resistant to configuration drift

This module is the **foundation of EPIC’s security posture**.

---

## Summary (Read This If Nothing Else)

- This role **cannot be wrong**
- This role **must not be complicated**
- Simplicity is enforced at the EPIC layer
- Power exists, but is hidden by default
- Most users only declare *intent*

If IAM is done correctly here, **everything built on EPIC is safer by default**.

