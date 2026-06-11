# EPIC AWS RDS Proxy Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-aws-rds-proxy
**Module Type:** Tier 0 – Foundational Infrastructure Module

---

## Overview

This repository provides the **foundational AWS RDS Proxy Terraform module** used by PG&E's **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

The module creates a single RDS Proxy with a default target group registered against an Aurora cluster (or a single RDS instance). Per PG&E SAF 2.0 RDS Proxy guardrails, this module enforces:

- `require_tls=true` (the SAF's TLS requirement)
- `iam_auth=REQUIRED` by default (clients authenticate via IAM database authentication; the proxy authenticates to the database via the secret ARN)
- Caller-supplied secrets, IAM role, subnets, and security groups (no embedded org-specific identity)

This module is intentionally **low-level and policy-agnostic** — Lambda IAM grants for `rds-db:connect` are composed by higher-level modules.

---

## Design Principles

- TLS required (cannot be disabled via this module)
- IAM authentication enforced
- Debug logging forbidden
- Single proxy per module instance (per Aurora cluster / per environment)
- Caller composes the secret + role
- Naming convention enforced (`pge-epic-<app>-<env>-proxy`)

---

## SAF 2.0 Compliance

Enforced via Terraform `lifecycle` preconditions:

| SAF # | Control | Enforcement |
|---|---|---|
| #3 | TLS ≥ 1.2 | `require_tls=true` enforced |
| #6 | Logging discipline | `debug_logging=false` enforced (enhanced logging captures full SQL statement text) |
| #8 | Access controls | `iam_auth=REQUIRED` enforced; `secret_arns` must contain ≥ 1 entry |

Out of module scope: IAM role for the proxy (caller passes `role_arn`), `rds-db:connect` grants on Lambda roles, security group ingress (caller manages on the SG passed via `vpc_security_group_ids`), VPC endpoints.

---

## What This Module Is (and Is Not)

### This module IS
- A foundational RDS Proxy primitive
- A target-group + target binding
- A SAF-aligned secure-by-default proxy

### This module is NOT
- An IAM role module (caller passes `role_arn`)
- A Secrets Manager module
- A read-replica routing layer (single target per default group)
- An Aurora cluster module (use [epic-pipeline-module-aws-aurora-postgresql](../epic-pipeline-module-aws-aurora-postgresql/))

---

## Resources Created

- `aws_db_proxy`
- `aws_db_proxy_default_target_group`
- `aws_db_proxy_target`

---

## Inputs

### Required Inputs

| Name | Description |
|---|---|
| `app_name` | Application identifier |
| `environment` | Deployment environment |
| `tags` | Resource tags |
| `engine_family` | `POSTGRESQL`, `MYSQL`, or `SQLSERVER` |
| `secret_arns` | List of Secrets Manager ARNs (≥ 1) |
| `role_arn` | IAM role the proxy assumes |
| `vpc_subnet_ids` | Private subnet IDs (≥ 2) |
| `vpc_security_group_ids` | SGs assigned to the proxy |

Plus exactly one of `target_db_cluster_identifier` / `target_db_instance_identifier`.

### Optional Inputs

| Name | Description | Default |
|---|---|---|
| `custom_proxy_name` | Full proxy name override | `null` |
| `require_tls` | Enforce TLS on client connections | `true` |
| `iam_auth` | `REQUIRED`, `ENABLED`, or `DISABLED` | `REQUIRED` |
| `client_password_auth_type` | Client auth type | `null` |
| `auth_description` | Description on the auth block | `null` |
| `username` | Username override (defaults to secret) | `null` |
| `idle_client_timeout` | Client idle timeout (seconds) | `1800` |
| `debug_logging` | Enable enhanced logging (auto-disables 24h) | `false` |
| `connection_pool_config` | Pool config object | sensible defaults |

---

## Outputs

| Name | Description |
|---|---|
| `proxy_name` | Proxy name |
| `proxy_arn` | Proxy ARN |
| `proxy_endpoint` | Proxy hostname (clients connect here) |
| `target_group_name` | Default target group name |
| `target_group_arn` | Default target group ARN |
| `target_endpoint` | Endpoint of the registered target |

---

## Example Usage (Direct Terraform)

```hcl
module "aurora_proxy" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-rds-proxy.git"

  app_name    = "nfr-tool"
  environment = "dev"

  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  secret_arns            = [module.aurora.master_user_secret_arn]
  vpc_subnet_ids         = [data.aws_ssm_parameter.s1.value, data.aws_ssm_parameter.s2.value, data.aws_ssm_parameter.s3.value]
  vpc_security_group_ids = [module.aurora.security_group_id]

  target_db_cluster_identifier = module.aurora.cluster_identifier

  tags = module.tags.tags
}
```

Resolves to proxy name `pge-epic-nfr-tool-dev-proxy`.

---

## EPIC Usage (resources.yml)

```yaml
modules:
  - name: aurora-proxy
    path: epic-pipeline-module-aws-rds-proxy
    variables:
      app_name: ${app_name}
      environment: ${environment}
      engine_family: POSTGRESQL
      role_arn: ${aws_iam_role.rds_proxy.arn}
      secret_arns:
        - ${module.aurora.master_user_secret_arn}
      vpc_subnet_ids: ${data.private_subnet_ids}
      vpc_security_group_ids:
        - ${module.aurora.security_group_id}
      target_db_cluster_identifier: ${module.aurora.cluster_identifier}
      tags: module.tags.tags
```

---

## Naming Conventions

Default proxy name resolves to:

```text
pge-epic-<app_name>-<environment>-proxy
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
