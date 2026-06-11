# EPIC AWS KMS Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-kms
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS KMS Customer-Managed Key (CMK) Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module creates a single CMK and a single alias, with a SAF-aligned default key policy that grants:

1. Account root admin (`kms:*`)
2. `SecurityAdmin` role lifecycle actions (DeleteAlias / DisableKey / CancelKeyDeletion / EnableKey)
3. `PrismaCloudReadWriteMasterMemberRole-member` `kms:*` for compliance scanning
4. A `DenyFromInternet` statement scoped to PG&E CIDR space, with `aws:ViaAWSService` carve-out and an optional org-ID safety net

Caller may supply a fully-formed `policy_json` to override the default.

---

## Design Principles

- One CMK per data classification per purpose
- Annual rotation enforced (symmetric encryption keys)
- 30-day deletion window default; 7-day minimum
- Account-scoped — no cross-account principals on the default policy
- Deny-internet condition baked into the default policy
- Caller composes per-workload action grants via IAM role inline policies (NOT in the key policy)

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions and validations:

| SAF # | Control | Enforcement |
|---|---|---|
| #5 | Key rotation | `enable_key_rotation=true` enforced for symmetric ENCRYPT_DECRYPT keys |
| #7 | Deletion window | `deletion_window_in_days` validated 7–30; default 30 |
| #8 / #29 | Least-privilege management | `bypass_policy_lockout_safety_check=false` enforced; default policy grants `kms:*` only to account root, lifecycle subset to SecurityAdmin, full `kms:*` to Prisma compliance role |
| #19 | Internet segregation | Default policy includes `DenyFromInternet` scoped to PG&E CIDR space with `aws:ViaAWSService=false` carve-out |

Caller may supply `policy_json` to override; the override is the caller's responsibility to keep SAF-aligned.

Out of module scope: KMS VPC endpoint, per-workload IAM role inline policies (`kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey`, `kms:DescribeKey`).

---

## What This Module Is (and Is Not)

### This module IS
- A foundational symmetric/asymmetric CMK primitive
- A SAF-aligned default key policy
- Suitable for direct use by experienced Terraform users

### This module is NOT
- A grant-management layer (workload roles get `kms:Encrypt` / `kms:Decrypt` via their own IAM policies)
- A KMS VPC endpoint module
- A multi-key fleet manager (call it once per CMK)

---

## Resources Created

- `aws_kms_key`
- `aws_kms_alias`

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment (dev, test, qa, prod) |
| `tags` | Resource tags |
| `purpose` | Suffix for the alias (e.g., `aurora`, `secrets`) |
| `description` | Human-readable description |

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_alias` | Full alias override (`alias/...`) | `null` |
| `key_usage` | `ENCRYPT_DECRYPT`, `SIGN_VERIFY`, `GENERATE_VERIFY_MAC` | `ENCRYPT_DECRYPT` |
| `customer_master_key_spec` | Key material spec | `SYMMETRIC_DEFAULT` |
| `deletion_window_in_days` | Pending-deletion window (7–30) | `30` |
| `enable_key_rotation` | Enable annual rotation (symmetric only) | `true` |
| `multi_region` | Create as multi-region key | `false` |
| `is_enabled` | Whether the key is enabled | `true` |
| `bypass_policy_lockout_safety_check` | Bypass policy lockout check | `false` |
| `policy_json` | Raw JSON key policy override | `null` |
| `security_admin_role_name` | Role granted lifecycle actions on default policy | `SecurityAdmin` |
| `prisma_role_name` | Role granted compliance access on default policy | `PrismaCloudReadWriteMasterMemberRole-member` |
| `internal_cidr_blocks` | CIDRs allowed by `DenyFromInternet` | PG&E ranges |
| `principal_org_id` | Org ID used in the safety-net condition | `null` |

---

## Outputs

| Name | Description |
|---|---|
| `key_id` | KMS key ID |
| `key_arn` | KMS key ARN |
| `alias_name` | Alias name |
| `alias_arn` | Alias ARN |
| `key_rotation_enabled` | Resolved rotation flag |

---

## Example Usage (Direct Terraform)

```hcl
module "aurora_key" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-kms.git"

  app_name    = "nfr-tool"
  environment = "dev"
  purpose     = "aurora"
  description = "Encrypts the NFR Tool Aurora cluster + automated/manual snapshots."

  principal_org_id = "o-abc123"

  tags = module.tags.tags
}
```

Resolves to alias `alias/pge-epic-nfr-tool-dev-aurora`.

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: aurora-key
    path: epic-pipeline-module-aws-kms
    variables:
      app_name: ${app_name}
      environment: ${environment}
      purpose: aurora
      description: "Encrypts the NFR Tool Aurora cluster + snapshots."
      tags: module.tags.tags
```

---

## Naming Conventions

Default alias resolves to:

```text
alias/pge-epic-<app_name>-<environment>-<purpose>
```

---

## Terraform Compatibility

- Terraform >= 1.5
- AWS Provider >= 5.x

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.
