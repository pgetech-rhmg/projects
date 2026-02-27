# EPIC IAM Role Contract

**Module:** pge-pipeline-module-aws-iam-role  
**Tier:** Tier 0 – Foundational Infrastructure  
**Owner:** PG&E Enterprise Cloud & DevSecOps  
**Last Updated:** 2025-12-18

---

## Purpose

This document defines the **authoritative contract** for IAM roles created through EPIC using the
`pge-pipeline-module-aws-iam-role` module.

It exists to clearly describe:

- What EPIC guarantees
- What EPIC controls
- What consumers are allowed to specify
- How security consistency is enforced

This contract is **implementation-agnostic** and applies regardless of how Terraform or AWS evolve.

---

## Core Principle

> **IAM roles in EPIC are defined by intent, not implementation.**

Application teams describe *what a role is for*.  
EPIC determines *how that role is securely implemented*.

---

## Supported Role Types (Level 1)

The following `role_type` values are the **only supported intent-based roles** exposed to consumers:

| role_type | Intended Use |
|---------|--------------|
| terraform | EPIC Terraform execution roles |
| cicd | CI/CD pipeline roles |
| lambda | AWS Lambda execution roles |
| ecs | AWS ECS task execution roles |
| readonly | Read-only access roles |
| cross_account | Explicit cross-account access |

If a role does not fit one of these categories, it must be reviewed by the platform team.

---

## Trust Model Contract

Each `role_type` maps to a **predefined trust model** controlled by EPIC.

| role_type | Trust Mechanism |
|---------|----------------|
| terraform | OIDC (Azure DevOps) |
| cicd | OIDC (ADO / GitHub) |
| lambda | AWS Service Principal |
| ecs | AWS Service Principal |
| readonly | AWS Principal |
| cross_account | AWS Principal |

Consumers **cannot override trust behavior** unless explicitly using the escape hatch.

---

## Default Permissions Contract

EPIC enforces **least privilege by default**.

Each role type is assigned default permissions internally.  
Consumers do not need to request them.

Additional permissions may only be added via approved capabilities.

---

## Capability Model (Level 2)

Capabilities are **named, enterprise-approved permission bundles**.

Examples include:

- s3_read
- s3_write
- logs_write
- secrets_read
- dynamodb_rw
- kms_decrypt

Capabilities:
- Are additive
- Never weaken security
- Are centrally defined and reviewed

Consumers do not attach IAM policies directly at this level.

---

## Escape Hatch (Level 3)

For exceptional cases, EPIC provides an explicit escape hatch.

To activate:

```
custom_trust: true
```

Once enabled:
- EPIC does not generate trust policies
- All trust relationships must be explicitly defined
- IAM expertise is required
- Usage should be reviewed by security

This mode exists to enable flexibility, not convenience.

---

## What EPIC Guarantees

EPIC guarantees that IAM roles created through this module are:

- Explicitly trusted
- Least-privileged by default
- Consistently named and tagged
- Auditable across all accounts
- Resistant to configuration drift

---

## What Consumers Can Expect

Consumers can expect:

- Simple, intent-based configuration
- No requirement to understand IAM or Terraform
- Stable role behavior over time
- Backward compatibility when contracts evolve

---

## What This Contract Prevents

This contract explicitly prevents:

- Copy-paste IAM roles
- Inline trust logic in application code
- Undocumented permission creep
- Environment-specific IAM drift
- Ad-hoc security exceptions

---

## Contract Stability

This contract is **versioned and intentionally stable**.

Breaking changes to this contract:
- Require security review
- Must be communicated clearly
- Are avoided whenever possible

---

## Summary

The EPIC IAM Role Contract ensures that:

- IAM is boring
- Security is consistent
- Application teams stay productive
- Platform teams retain control

If IAM is correct here, **everything built on EPIC inherits that correctness**.

