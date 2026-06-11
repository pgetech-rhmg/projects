# EPIC AWS Aurora PostgreSQL Module

## Overview

Provisions an Amazon Aurora PostgreSQL cluster for an EPIC-managed application. The module creates the cluster, its writer/reader instances, a DB subnet group, cluster and instance parameter groups, and a dedicated security group. It is built for the EPIC pipeline contract — `app_name`, `environment`, and `tags` are injected by the pipeline at apply time, and resource names are derived as `pge-epic-<app_name>-<environment>-*`.

The module enforces SAF (Secure-At-First) defaults: storage encryption is on, `publicly_accessible` is locked to `false`, `rds.force_ssl=1` must be present in the cluster parameter group, backup retention is at least 15 days, and a CMK is required when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged`. Master credentials default to AWS-managed (rotated by RDS into Secrets Manager); a static `master_password` may be supplied instead, but not both.

Serverless v2 is opt-in via `serverlessv2_scaling_configuration` and `instance_class = "db.serverless"`. With an empty scaling map, the cluster runs as provisioned.

## Resources

- `aws_rds_cluster.this` — Aurora PostgreSQL cluster
- `aws_rds_cluster_instance.this` — writer + reader instances (count = `instance_count`)
- `aws_db_subnet_group.this` — DB subnet group across the supplied private subnets
- `aws_rds_cluster_parameter_group.this` — cluster parameters (defaults enforce `rds.force_ssl=1`)
- `aws_db_parameter_group.this` — instance parameters
- `aws_security_group.this` — cluster security group
- `aws_vpc_security_group_ingress_rule.from_sg` — per-SG ingress on the cluster port
- `aws_vpc_security_group_ingress_rule.from_cidr` — per-CIDR ingress on the cluster port

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name. Drives resource naming as `pge-epic-<app_name>-<environment>-*`. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `tags` | `map(string)` | Common tags applied to every resource. Set `DataClassification` here — when it is `Confidential`, `Restricted`, or `Privileged`, `kms_key_id` becomes mandatory. |
| `vpc_id` | `string` | VPC ID for the Aurora security group. |
| `subnet_ids` | `list(string)` | Private subnet IDs for the DB subnet group. Must contain at least 2 subnets across distinct AZs. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_cluster_identifier` | `string` | `null` | Full cluster identifier override. |
| `custom_db_cluster_parameter_group_name` | `string` | `null` | Full DB cluster parameter group name override. |
| `custom_db_parameter_group_name` | `string` | `null` | Full DB instance parameter group name override. |
| `custom_db_subnet_group_name` | `string` | `null` | Full DB subnet group name override. |
| `custom_security_group_name` | `string` | `null` | Full security group name override. |
| `engine_version` | `string` | `"16.4"` | Aurora PostgreSQL engine version. |
| `engine_mode` | `string` | `"provisioned"` | Engine mode. `provisioned` supports Serverless v2 via the scaling configuration. |
| `family` | `string` | `"aurora-postgresql16"` | DB parameter group family. |
| `database_name` | `string` | `null` | Initial database name. |
| `port` | `number` | `5432` | Port the cluster listens on. |
| `master_username` | `string` | `"epic_master"` | Master DB username. |
| `master_password` | `string` | `null` | Master DB password. Required unless `manage_master_user_password = true`. Mutually exclusive with the AWS-managed credential. |
| `manage_master_user_password` | `bool` | `true` | If true, AWS manages the master credential in Secrets Manager. |
| `master_user_secret_kms_key_id` | `string` | `null` | KMS key for the AWS-managed master credential secret. Required for non-Internal/non-Public `DataClassification`. |
| `kms_key_id` | `string` | `null` | KMS Key ARN for cluster + snapshot encryption. Mandatory for Confidential / Restricted / Privileged data. |
| `storage_encrypted` | `bool` | `true` | Storage encryption flag. SAF requires `true`. |
| `iam_database_authentication_enabled` | `bool` | `false` | Enable IAM database authentication. Set `false` when fronted by RDS Proxy. |
| `serverlessv2_scaling_configuration` | `map(any)` | `{}` | Serverless v2 scaling configuration (`min_capacity`, `max_capacity`). Empty map disables Serverless v2. |
| `backup_retention_period` | `number` | `30` | Backup retention in days. SAF requires `>= 15`. |
| `preferred_backup_window` | `string` | `null` | Daily backup window (UTC). |
| `preferred_maintenance_window` | `string` | `null` | Weekly maintenance window (UTC). |
| `deletion_protection` | `bool` | `true` | Enable deletion protection. |
| `skip_final_snapshot` | `bool` | `false` | Skip the final snapshot on delete. |
| `final_snapshot_identifier` | `string` | `null` | Final snapshot identifier. |
| `apply_immediately` | `bool` | `false` | Apply cluster modifications immediately. |
| `allow_major_version_upgrade` | `bool` | `false` | Allow major version upgrades when changing `engine_version`. |
| `enabled_cloudwatch_logs_exports` | `list(string)` | `["postgresql"]` | Log types to export to CloudWatch. |
| `cluster_parameters` | `list(map(string))` | `[{rds.force_ssl=1}, {log_statement=mod}]` | DB cluster parameters. Must include `rds.force_ssl=1`. |
| `instance_parameters` | `list(map(string))` | `[]` | DB instance parameters. |
| `instance_count` | `number` | `1` | Number of instances (writer + readers). Minimum 1. |
| `instance_class` | `string` | `"db.serverless"` | Instance class. Use `db.serverless` for Serverless v2; `db.r6g.large` or larger for provisioned. |
| `performance_insights_enabled` | `bool` | `true` | Enable Performance Insights on each instance. |
| `performance_insights_kms_key_id` | `string` | `null` | KMS Key ARN for Performance Insights data. |
| `performance_insights_retention_period` | `number` | `7` | Performance Insights retention (`7` or `731`). |
| `monitoring_interval` | `number` | `60` | Enhanced monitoring interval in seconds (`0`, `1`, `5`, `10`, `15`, `30`, `60`). |
| `monitoring_role_arn` | `string` | `null` | IAM role ARN used by Enhanced Monitoring. Required when `monitoring_interval > 0`. |
| `publicly_accessible` | `bool` | `false` | Whether instances are publicly accessible. SAF requires `false`. |
| `auto_minor_version_upgrade` | `bool` | `true` | Apply minor engine upgrades during the maintenance window. |
| `ingress_security_group_ids` | `list(string)` | `[]` | Security group IDs allowed to connect on the cluster port. |
| `ingress_cidr_blocks` | `list(string)` | `[]` | CIDR blocks allowed to connect on the cluster port. Prefer SG-to-SG. |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | Aurora cluster ID. |
| `cluster_identifier` | Aurora cluster identifier. |
| `cluster_arn` | Aurora cluster ARN. |
| `cluster_resource_id` | Cluster resource ID (used for IAM database authentication). |
| `cluster_endpoint` | Writer (cluster) endpoint. |
| `reader_endpoint` | Reader endpoint. |
| `port` | Cluster port. |
| `database_name` | Initial database name. |
| `master_username` | Master username. |
| `master_user_secret_arn` | ARN of the AWS-managed master credential secret (when `manage_master_user_password = true`). |
| `instance_endpoints` | Per-instance endpoints. |
| `instance_identifiers` | Per-instance identifiers. |
| `security_group_id` | Aurora security group ID. |
| `security_group_arn` | Aurora security group ARN. |
| `db_subnet_group_name` | DB subnet group name. |
| `db_cluster_parameter_group_name` | DB cluster parameter group name. |
| `db_parameter_group_name` | DB instance parameter group name. |

## Usage in a Terraform project

This is the canonical call from an application's `.infra/aurora.tf`. The pipeline supplies `app_name`, `environment`, and `tags` from `.pipeline/epic.json`; the application supplies network and KMS inputs.

```hcl
###############################################################################
# Aurora Serverless v2 PostgreSQL — single cluster per environment per
# Requirements §4.2.1 and create.md §10.1.
#
# - manage_master_user_password = true   → RDS owns the master secret in SM
# - iam_database_authentication_enabled = false → proxy is the auth boundary
# - storage encryption via the kms_aurora CMK
# - cluster SG accepts 5432 ingress from the proxy SG only
###############################################################################

module "aurora_postgresql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-aurora-postgresql.git?ref=main"

  app_name    = var.project_tag
  environment = var.environment
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  subnet_ids  = local.private_subnet_ids

  engine_version                      = var.aurora_engine_version
  manage_master_user_password         = true
  kms_key_id                          = module.kms_aurora.key_arn
  iam_database_authentication_enabled = false

  serverlessv2_scaling_configuration = {
    min_capacity = var.aurora_min_capacity
    max_capacity = var.aurora_max_capacity
  }

  enabled_cloudwatch_logs_exports = ["postgresql"]

  cluster_parameters = [{
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }]

  ingress_security_group_ids = [module.aurora_proxy_security_group.aws_security_group_id]

  tags = module.tags.tags
}
```

## Usage from another module

When wrapping this module from another Terraform module, forward the EPIC-injected inputs through and let the caller supply network and KMS:

```hcl
module "aurora_postgresql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-aurora-postgresql.git?ref=main"

  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  manage_master_user_password = true
  kms_key_id                  = var.kms_key_arn

  serverlessv2_scaling_configuration = {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  ingress_security_group_ids = var.ingress_security_group_ids
}
```

Re-export anything the parent module's caller needs (for example `cluster_endpoint`, `reader_endpoint`, `security_group_id`, `master_user_secret_arn`).

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- `manage_master_user_password = true` and `master_password` are mutually exclusive — set one or the other, not both.
- When `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged`, `kms_key_id` is required and the apply will fail without it.
- `cluster_parameters` must include an entry with `name = "rds.force_ssl"` and `value = "1"`. Replacing the default list without re-adding this entry will fail validation.
- `subnet_ids` must contain at least 2 subnets in distinct AZs; the cluster only accepts private subnets.
- For Serverless v2, set `instance_class = "db.serverless"` (the default) and pass `min_capacity` / `max_capacity` in `serverlessv2_scaling_configuration`. Leaving the map empty runs the cluster as provisioned and requires a non-serverless `instance_class`.
- When `monitoring_interval > 0`, `monitoring_role_arn` must be set.
