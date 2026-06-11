# EPIC AWS Aurora PostgreSQL Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-aurora-postgresql
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS Aurora PostgreSQL Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

The module creates a single Aurora PostgreSQL cluster (Serverless v2 by default) with one or more cluster instances, a cluster parameter group with `rds.force_ssl=1`, an instance parameter group, a subnet group, and a security group. The cluster is private-only (`publicly_accessible=false` enforced) and storage-encrypted.

Per PG&E SAF 2.0 Aurora PostgreSQL guardrails:
- `BackupRetentionPeriod` ≥ 15 days (module enforces a default of 30)
- KMS CMK encryption (caller-supplied)
- TLS-only via `rds.force_ssl=1`
- IAM database authentication is **off** by default — typical EPIC deployments front Aurora with [epic-pipeline-module-aws-rds-proxy](../epic-pipeline-module-aws-rds-proxy/) (the proxy authenticates Lambdas via IAM and authenticates to Aurora via the master credential)

---

## Design Principles

- Private subnets only — `publicly_accessible: false` enforced
- Storage encryption on by default
- TLS-only via `rds.force_ssl=1` cluster parameter
- AWS-managed master credential rotation by default (`manage_master_user_password=true`)
- Deletion protection on by default
- Naming convention enforced (`pge-epic-<app>-<env>-cluster`)
- Caller composes IAM grants (`rds-db:connect`, secret access)

---

## SAF 2.0 Compliance

This module enforces the following SAF 2.0 controls via Terraform `lifecycle` preconditions — `terraform plan` fails if a precondition is violated:

| SAF # | Control | Enforcement |
|---|---|---|
| #1 | Encrypt data at rest | `storage_encrypted=true` enforced |
| #2 | PG&E-managed CMK | `kms_key_id` mandatory when `tags["DataClassification"]` is `Confidential`, `Restricted`, or `Privileged` |
| #3 | TLS ≥ 1.2 | `cluster_parameters` must include `rds.force_ssl=1` |
| #7 | Backup retention | `backup_retention_period >= 15` validated |
| #21 | Internet segregation | `publicly_accessible=false` enforced on cluster + each instance |
| #28 | Monitoring | `monitoring_role_arn` required when `monitoring_interval > 0` |

Defaults that are SAF-aligned but the caller can opt out of: deletion protection on, AWS-managed master password (Secrets Manager) on, `log_statement=mod` (pgaudit baseline), `enabled_cloudwatch_logs_exports=["postgresql"]`, multi-AZ via `instance_count >= 2`.

Out of module scope (caller composes): per-PG-role grants via migration tool, VPC endpoint provisioning, RDS Proxy fronting (use `epic-pipeline-module-aws-rds-proxy`), IAM `rds-db:connect` policies, full 9-tag block (use `epic-pipeline-module-aws-tags`).

---

## What This Module Is (and Is Not)

### This module IS
- A foundational Aurora PostgreSQL cluster primitive
- A SAF-aligned secure-by-default cluster

### This module is NOT
- An RDS Proxy module (use [epic-pipeline-module-aws-rds-proxy](../epic-pipeline-module-aws-rds-proxy/))
- A KMS module (use [epic-pipeline-module-aws-kms](../epic-pipeline-module-aws-kms/))
- A migration tool runner
- A schema / role manager (per-PG-role grants are owned by application migrations)

---

## Resources Created

- `aws_db_subnet_group`
- `aws_security_group` + `aws_vpc_security_group_ingress_rule` (per allowed SG / CIDR)
- `aws_rds_cluster_parameter_group`
- `aws_db_parameter_group`
- `aws_rds_cluster`
- `aws_rds_cluster_instance` (one per `instance_count`)

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment |
| `tags` | Resource tags |
| `vpc_id` | VPC for the security group |
| `subnet_ids` | Private subnet IDs (≥ 2 across AZs) |

### Optional Inputs (selected)

| Name | Description | Default |
|---|---|---|
| `engine_version` | Aurora PostgreSQL version | `16.4` |
| `family` | Parameter group family | `aurora-postgresql16` |
| `database_name` | Initial database name | `null` |
| `master_username` | Master DB username | `epic_master` |
| `manage_master_user_password` | AWS-managed credential rotation | `true` |
| `kms_key_id` | CMK for storage encryption | `null` |
| `iam_database_authentication_enabled` | Enable IAM DB auth | `false` |
| `serverlessv2_scaling_configuration` | `{ min_capacity, max_capacity }` | `{}` |
| `backup_retention_period` | Backup retention in days (≥ 15) | `30` |
| `deletion_protection` | Enable deletion protection | `true` |
| `enabled_cloudwatch_logs_exports` | Log types exported | `["postgresql"]` |
| `cluster_parameters` | DB cluster parameters | TLS-required + `log_statement=mod` |
| `instance_count` | Writer + reader count | `1` |
| `instance_class` | Instance class | `db.serverless` |
| `performance_insights_enabled` | Enable PI on each instance | `true` |
| `monitoring_interval` | Enhanced monitoring interval | `60` |
| `monitoring_role_arn` | Enhanced monitoring role | `null` |
| `ingress_security_group_ids` | SGs allowed to connect | `[]` |
| `ingress_cidr_blocks` | CIDRs allowed to connect | `[]` |

See `variables.tf` for the full list.

---

## Outputs

| Name | Description |
|---|---|
| `cluster_endpoint` | Writer endpoint |
| `reader_endpoint` | Reader endpoint |
| `cluster_arn` | Cluster ARN |
| `cluster_resource_id` | Used for IAM DB authentication |
| `master_user_secret_arn` | ARN of AWS-managed master secret (when applicable) |
| `security_group_id` | Aurora SG ID |
| `db_subnet_group_name` | Subnet group |
| `instance_endpoints` | List of per-instance endpoints |

See `outputs.tf` for the full list.

---

## Example Usage (Direct Terraform)

```hcl
module "aurora" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-aurora-postgresql.git"

  app_name    = "nfr-tool"
  environment = "dev"

  vpc_id     = data.aws_ssm_parameter.vpc_id.value
  subnet_ids = [
    data.aws_ssm_parameter.private_subnet1.value,
    data.aws_ssm_parameter.private_subnet2.value,
    data.aws_ssm_parameter.private_subnet3.value,
  ]

  database_name = "nfr"
  kms_key_id    = module.aurora_key.key_arn

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 4
  }

  ingress_security_group_ids = [module.lambda_sg.id]

  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  performance_insights_kms_key_id = module.aurora_key.key_arn

  tags = module.tags.tags
}
```

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: aurora
    path: epic-pipeline-module-aws-aurora-postgresql
    variables:
      app_name: ${app_name}
      environment: ${environment}
      vpc_id: ${data.vpc_id}
      subnet_ids: ${data.private_subnet_ids}
      database_name: nfr
      kms_key_id: ${module.aurora_key.key_arn}
      tags: module.tags.tags
```

---

## Naming Conventions

Default cluster identifier resolves to:

```text
pge-epic-<app_name>-<environment>-cluster
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
