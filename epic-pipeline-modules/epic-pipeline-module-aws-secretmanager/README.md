# EPIC AWS Secrets Manager Module

## Overview

Provisions an AWS Secrets Manager secret for an EPIC-managed application, attaches the PG&E compliance resource policy (optionally merged with a caller-supplied policy), and emits a read-only IAM policy that EC2 instances or Lambda functions can attach to retrieve the secret at runtime.

The secret name follows the EPIC convention: `pge-epic-{app_name}-{environment}-secrets`. The associated read policy is named `pge-epic-{app_name}-{environment}-secret-read`.

This module is consumed by application `.infra/` Terraform when an app declares its infrastructure via `.pipeline/epic.json` and EPIC's DeployInfra stage runs `terraform apply`.

---

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_secretsmanager_secret.sm` | The Secrets Manager secret. Resource policy is the merge of `pge_compliance_policy.json` and `var.custom_policy`. |
| `aws_secretsmanager_secret_version.sm_secret_version` | Initial version written from `var.secrets` (created only when `secret_version_enabled = true` and `secrets` is non-empty). `ignore_changes = all` so out-of-band rotations are not reverted. |
| `aws_secretsmanager_secret_rotation.sm_secret_rotation` | Rotation schedule (created only when `rotation_enabled = true`). |
| `aws_iam_policy.secret_read` | Standalone IAM policy granting `secretsmanager:GetSecretValue` on this secret. ARN exposed as `secret_read_arn` for attachment to EC2 instance profiles or Lambda execution roles. |

The secret's resource block uses `lifecycle { ignore_changes = all }` after creation. To rotate values managed by this module, do so in AWS Secrets Manager directly or replace the secret.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name, used in the secret and IAM policy names. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `tags` | `map(string)` | Common tags. Must include a `DataClassification` key — values other than `Internal` or `Public` require `kms_key_id` to be set (enforced by precondition). |
| `secrets_description` | `string` | Description applied to the secret. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `secrets` | `map(string)` | `{}` | Key/value pairs serialized to JSON and written as the initial secret version. Only written when `secret_version_enabled` is `true`. |
| `secret_version_enabled` | `bool` | `false` | If `true` and `secrets` is non-empty, write an initial `aws_secretsmanager_secret_version`. |
| `kms_key_id` | `string` | `null` | KMS key ARN or ID for encryption. Required when `tags["DataClassification"]` is not `Internal` or `Public`. |
| `recovery_window_in_days` | `number` | `30` | Deletion recovery window. Must be `0` (immediate delete) or between `7` and `30`. |
| `custom_policy` | `string` | `"{}"` | JSON resource policy merged on top of the bundled PG&E compliance policy. Must parse as valid JSON. |
| `rotation_enabled` | `bool` | `false` | Enable scheduled rotation. |
| `rotation_lambda_arn` | `string` | `null` | Lambda ARN that performs rotation. Required when `rotation_enabled` is `true`. |
| `rotation_after_days` | `number` | `null` | Rotation interval in days. |
| `prefix_name` | `string` | `null` | Reserved for prefix-based naming. Not used by current resources. |

---

## Outputs

| Name | Description |
|------|-------------|
| `arn` | ARN of the Secrets Manager secret. |
| `secret_read_arn` | ARN of the read-only IAM policy. **Attach this to EC2 instance profiles or Lambda execution roles** that need to call `GetSecretValue` against the secret. |
| `version_ids` | Map of created secret version IDs (empty unless `secret_version_enabled = true`). |
| `rotation_enabled` | Echoes the `rotation_enabled` input. |
| `secrets` | Full `aws_secretsmanager_secret` resource object. |

---

## Usage in a Project

Canonical call from `epic-api/.infra/main.tf` — the EPIC API merges its RDS-managed master secret ARN and cluster endpoint into `secrets` so the application can resolve the database connection string at boot from a single secret:

```hcl
module "secretmanager" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-secretmanager.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = module.tags.tags

  secrets = merge(var.secrets, {
    "AWS_RDS_SECRET_ARN" = aws_rds_cluster.epic.master_user_secret[0].secret_arn
    "AWS_RDS_ENDPOINT"   = aws_rds_cluster.epic.endpoint
  })

  secrets_description     = var.secrets_description
  secret_version_enabled  = true
  recovery_window_in_days = 0
}
```

The resulting `module.secretmanager.secret_read_arn` is then attached to the EC2 instance profile created by the EC2 module so the running application can read the secret:

```hcl
module "ec2" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  # ...

  iam = {
    create_instance_profile = true
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      module.secretmanager.secret_read_arn,
      aws_iam_policy.rds_secret_read.arn,
    ]
  }
}
```

### Empty Secret (Populated Out-of-Band)

When the secret values are managed manually or by another system after creation, omit `secrets` and `secret_version_enabled`. The module creates the secret and the read policy without writing an initial version:

```hcl
module "secrets_entraid_client" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-secretmanager.git?ref=main"

  app_name            = var.project_tag
  environment         = var.environment
  secrets_description = "EntraID app-registration client secret."
  kms_key_id          = module.kms_secrets.key_arn
  tags                = module.tags.tags
}
```

---

## Composition

This module pairs with:

- `epic-pipeline-module-aws-tags` — supplies the `tags` map (including `DataClassification`, which gates the `kms_key_id` precondition).
- `epic-pipeline-module-aws-ec2` / Lambda modules — consume `secret_read_arn` via `iam.policy_arns` (EC2) or attach it to a Lambda execution role.
- `epic-pipeline-module-aws-kms` — supplies `kms_key_id` for non-`Internal`/`Public` data classifications.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS provider | `~> 5.90` |

---

## Notes

- `recovery_window_in_days = 0` forces immediate deletion with no recovery window. EPIC-managed apps typically use `0` in non-prod and the default `30` in prod.
- The secret resource has `ignore_changes = all`, so updates to `secrets`, `tags`, `description`, or policy after the initial apply will not propagate. Replace the secret to change tracked attributes.
- The bundled `pge_compliance_policy.json` is always applied as the resource policy base; `custom_policy` is overlaid on top via `override_policy_documents`.
- The `kms_key_id` precondition fires at plan time when `tags["DataClassification"]` is missing or set to anything other than `Internal` or `Public` and no KMS key is supplied.
