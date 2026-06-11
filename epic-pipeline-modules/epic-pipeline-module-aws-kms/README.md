# EPIC AWS KMS Module

## Overview

Terraform module that provisions a single AWS KMS Customer-Managed Key (CMK) and a single alias for the EPIC (Enterprise Pipeline for Infrastructure and Cloud) platform.

The module ships with a SAF-aligned default key policy that grants:

1. Account root admin (`kms:*`)
2. A `SecurityAdmin` role lifecycle actions (`DeleteAlias`, `DisableKey`, `CancelKeyDeletion`, `EnableKey`)
3. A Prisma Cloud compliance role full `kms:*` for scanning
4. A `DenyFromInternet` statement scoped to PG&E CIDR space, with an `aws:ViaAWSService` carve-out and an optional `aws:PrincipalOrgID` safety net

A caller may supply a fully-formed `policy_json` to replace the default policy entirely.

The default alias resolves to:

```
alias/pge-epic-<app_name>-<environment>-<purpose>
```

Set `custom_alias` to override the auto-derived alias (must start with `alias/`).

## Resources

- `aws_kms_key`
- `aws_kms_alias`

## Inputs

### Required

| Name | Type | Description |
|---|---|---|
| `app_name` | `string` | Application name used for naming the key alias. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `tags` | `map(string)` | Common tags applied to the key. |
| `purpose` | `string` | Purpose suffix for the key alias (e.g., `aurora`, `secrets`, `audit`). Combined into `alias/pge-epic-<app>-<env>-<purpose>`. |
| `description` | `string` | Human-readable description of the key. |

### Optional

| Name | Type | Default | Description |
|---|---|---|---|
| `custom_alias` | `string` | `null` | Full alias override (must start with `alias/`). Takes precedence over the auto-derived alias. |
| `key_usage` | `string` | `ENCRYPT_DECRYPT` | Intended use of the key. One of `ENCRYPT_DECRYPT`, `SIGN_VERIFY`, `GENERATE_VERIFY_MAC`. |
| `customer_master_key_spec` | `string` | `SYMMETRIC_DEFAULT` | Type of key material. Use `SYMMETRIC_DEFAULT` for symmetric encryption; asymmetric specs are valid for `SIGN_VERIFY`. |
| `deletion_window_in_days` | `number` | `30` | Waiting period in days before pending key deletion (7 to 30). |
| `enable_key_rotation` | `bool` | `true` | Enable automatic annual key rotation. Required for symmetric `ENCRYPT_DECRYPT` keys. |
| `multi_region` | `bool` | `false` | Create the key as multi-region. |
| `is_enabled` | `bool` | `true` | Specifies whether the key is enabled. |
| `bypass_policy_lockout_safety_check` | `bool` | `false` | Bypass the safety check that prevents creating a key policy that locks out the principal updating it. Must remain `false`. |
| `policy_json` | `string` | `null` | Raw JSON key policy override. When `null`, the SAF-aligned default policy is generated. |
| `security_admin_role_name` | `string` | `SecurityAdmin` | Name of the IAM role granted lifecycle management actions on the default policy. |
| `prisma_role_name` | `string` | `PrismaCloudReadWriteMasterMemberRole-member` | Name of the IAM role granted `kms:*` for compliance scanning on the default policy. |
| `internal_cidr_blocks` | `list(string)` | PG&E internal ranges | CIDR blocks allowed by the `DenyFromInternet` condition on the default policy. |
| `principal_org_id` | `string` | `null` | PG&E AWS Organizations ID used in the `DenyFromInternet` carve-out. When `null`, the org-id condition is omitted. |

## Outputs

| Name | Description |
|---|---|
| `key_id` | KMS key ID. |
| `key_arn` | KMS key ARN. |
| `alias_name` | KMS key alias name. |
| `alias_arn` | KMS key alias ARN. |
| `key_rotation_enabled` | Whether automatic key rotation is enabled. |

## Usage in a Terraform project

Place the following in the application's `.infra/kms.tf` (referenced by `app.infraPath` in `.pipeline/epic.json`). One CMK per data-classification boundary.

```hcl
module "kms_aurora" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-kms.git?ref=main"

  app_name                 = var.project_tag
  environment              = var.environment
  purpose                  = "aurora"
  description              = "CMK for the NFR Tool Aurora cluster (storage encryption + master-user-password)."
  enable_key_rotation      = true
  security_admin_role_name = var.kms_security_admin_role_name
  prisma_role_name         = var.kms_prisma_role_name
  internal_cidr_blocks     = var.pge_cidr_allowlist
  principal_org_id         = var.principal_orgid

  tags = module.tags.tags
}

module "kms_lambda" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-kms.git?ref=main"

  app_name                 = var.project_tag
  environment              = var.environment
  purpose                  = "lambda-env"
  description              = "CMK for NFR Tool Lambda environment-variable encryption."
  enable_key_rotation      = true
  security_admin_role_name = var.kms_security_admin_role_name
  prisma_role_name         = var.kms_prisma_role_name
  internal_cidr_blocks     = var.pge_cidr_allowlist
  principal_org_id         = var.principal_orgid

  tags = module.tags.tags
}

module "kms_secrets" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-kms.git?ref=main"

  app_name                 = var.project_tag
  environment              = var.environment
  purpose                  = "secrets"
  description              = "CMK for NFR Tool Secrets Manager entries (per-assessment AIDLC API keys, EntraID secrets)."
  enable_key_rotation      = true
  security_admin_role_name = var.kms_security_admin_role_name
  prisma_role_name         = var.kms_prisma_role_name
  internal_cidr_blocks     = var.pge_cidr_allowlist
  principal_org_id         = var.principal_orgid

  tags = module.tags.tags
}
```

## Usage from another module

Compose this module from a higher-level module (e.g., a workload module that creates an Aurora cluster and the CMK that encrypts it) by forwarding identity and policy inputs:

```hcl
module "kms" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-kms.git?ref=main"

  app_name                 = var.app_name
  environment              = var.environment
  purpose                  = var.purpose
  description              = var.description
  enable_key_rotation      = true
  security_admin_role_name = var.security_admin_role_name
  prisma_role_name         = var.prisma_role_name
  internal_cidr_blocks     = var.internal_cidr_blocks
  principal_org_id         = var.principal_org_id

  tags = var.tags
}

resource "aws_rds_cluster" "this" {
  # ...
  kms_key_id        = module.kms.key_arn
  storage_encrypted = true
}
```

## Versions

| Requirement | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| AWS Provider | `~> 5.90` |

## Notes

- `enable_key_rotation` is only honored when `key_usage = ENCRYPT_DECRYPT` and `customer_master_key_spec = SYMMETRIC_DEFAULT`. For all other combinations, rotation is forced to `false` regardless of input.
- `bypass_policy_lockout_safety_check` is enforced to `false` via a `lifecycle.precondition`. Setting it to `true` will fail the plan.
- When `policy_json` is supplied, none of the `security_admin_role_name`, `prisma_role_name`, `internal_cidr_blocks`, or `principal_org_id` inputs are used — the override owns the entire policy document.
- Per-workload action grants (`kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey`, `kms:DescribeKey`) belong on the consuming IAM role's inline policy, not on the key policy.
