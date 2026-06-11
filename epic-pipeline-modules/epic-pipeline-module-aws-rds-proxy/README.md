# EPIC AWS RDS Proxy Module

## Overview

This module provisions an AWS RDS Proxy used by EPIC-managed applications to broker database connections between application compute (typically Lambda) and an Aurora cluster or RDS instance. The proxy authenticates to the database via Secrets Manager and accepts IAM-authenticated client connections.

The module is intentionally low-level: callers supply the secrets, IAM role, subnets, and security groups. Higher-level modules compose `rds-db:connect` grants and route application traffic through the proxy endpoint.

PG&E SAF guardrails are enforced as preconditions:

- `require_tls = true`
- `iam_auth = REQUIRED`
- `debug_logging = false` (enhanced logging captures full SQL; AWS auto-disables it after 24h regardless)
- At least one Secrets Manager ARN must be supplied
- Exactly one of `target_db_cluster_identifier` or `target_db_instance_identifier` must be supplied

## Resources

- `aws_db_proxy` — the proxy itself, with one `auth` block per supplied secret ARN
- `aws_db_proxy_default_target_group` — default target group with caller-tunable connection pool config
- `aws_db_proxy_target` — registers the Aurora cluster or RDS instance against the default target group

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used for naming the proxy. Injected by EPIC. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). Injected by EPIC. |
| `tags` | `map(string)` | Common tags applied to the proxy. |
| `engine_family` | `string` | Engine family for the proxy. One of `POSTGRESQL`, `MYSQL`, `SQLSERVER`. |
| `secret_arns` | `list(string)` | Secrets Manager secret ARNs holding database credentials the proxy uses to connect to the target. Must contain at least one ARN. |
| `role_arn` | `string` | IAM role ARN the proxy uses to access secrets and CloudWatch. |
| `vpc_subnet_ids` | `list(string)` | Private subnet IDs the proxy attaches to. Must contain at least 2 subnets across distinct AZs. |
| `vpc_security_group_ids` | `list(string)` | Security group IDs assigned to the proxy. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `custom_proxy_name` | `string` | `null` | Full proxy name override. When unset, the proxy is named `pge-epic-<app_name>-<environment>-proxy`. |
| `require_tls` | `bool` | `true` | Require TLS on connections to the proxy. SAF requires `true`. |
| `iam_auth` | `string` | `REQUIRED` | IAM authentication mode for client connections. One of `REQUIRED`, `DISABLED`, `ENABLED`. SAF requires `REQUIRED`. |
| `client_password_auth_type` | `string` | `null` | Client password auth type (e.g. `POSTGRES_SCRAM_SHA_256`, `POSTGRES_MD5`). |
| `auth_description` | `string` | `null` | Description of the authentication entry. |
| `username` | `string` | `null` | Username for the proxy auth block. When `null`, the proxy reads username from the secret. |
| `idle_client_timeout` | `number` | `1800` | Seconds a client connection can be inactive before being dropped. |
| `debug_logging` | `bool` | `false` | Enable enhanced debug logging. SAF requires `false`. |
| `target_db_cluster_identifier` | `string` | `null` | Aurora cluster identifier the proxy targets. Mutually exclusive with `target_db_instance_identifier`. |
| `target_db_instance_identifier` | `string` | `null` | RDS DB instance identifier the proxy targets. Mutually exclusive with `target_db_cluster_identifier`. |
| `connection_pool_config` | `object` | `{}` | Connection pool configuration for the default target group. See shape below. |

`connection_pool_config` object shape:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `max_connections_percent` | `number` | `100` | Max connections to the target as a percent of the target's max connections. |
| `max_idle_connections_percent` | `number` | `50` | Max idle connections retained in the pool. |
| `connection_borrow_timeout` | `number` | `120` | Seconds a client waits for a connection from the pool before failing. |
| `init_query` | `string` | `null` | SQL run on each new database connection. |
| `session_pinning_filters` | `list(string)` | `[]` | Session state pinning filters. |

## Outputs

| Name | Description |
|------|-------------|
| `proxy_name` | RDS Proxy name. |
| `proxy_arn` | RDS Proxy ARN. |
| `proxy_endpoint` | RDS Proxy endpoint hostname. |
| `target_group_name` | Default target group name. |
| `target_group_arn` | Default target group ARN. |
| `target_endpoint` | Endpoint of the registered target. |

## Usage in a Terraform Project

```hcl
module "rds_proxy" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-rds-proxy.git?ref=main"

  app_name      = var.project_tag
  environment   = var.environment
  engine_family = "POSTGRESQL"
  secret_arns   = [module.aurora_postgresql.master_user_secret_arn]
  role_arn      = module.rds_proxy_role.role_arn

  vpc_subnet_ids         = local.private_subnet_ids
  vpc_security_group_ids = [module.aurora_proxy_security_group.aws_security_group_id]

  connection_pool_config = {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
    require_tls                  = true
  }

  iam_auth                     = "REQUIRED"
  require_tls                  = true
  target_db_cluster_identifier = module.aurora_postgresql.cluster_identifier

  tags = module.tags.tags
}
```

## Usage From Another Module

When composed inside another EPIC module, source the same Git ref and forward `app_name`, `environment`, and `tags` from the parent module's variables so naming and tagging stay consistent across the stack:

```hcl
module "rds_proxy" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-rds-proxy.git?ref=main"

  app_name      = var.app_name
  environment   = var.environment
  tags          = var.tags
  engine_family = "POSTGRESQL"

  secret_arns            = var.secret_arns
  role_arn               = var.role_arn
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  target_db_cluster_identifier = var.aurora_cluster_identifier
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS Provider | `~> 5.90` |

## Notes

- The module does not export the proxy resource ID directly. Callers needing it for `rds-db:connect` IAM grants can parse it from `proxy_arn`: `element(split(":", module.rds_proxy.proxy_arn), 6)`.
- Applications integrate with this module through their own `.infra/` Terraform — the EPIC pipeline runs `terraform apply` against the app's `.infra/` directory based on the `app.infraPath` field in `.pipeline/epic.json`.
- The `auth` block is generated dynamically — one per entry in `secret_arns` — so multi-secret rotation scenarios are supported without changing the module.
