# EPIC Azure Container App Module

## Overview

`epic-pipeline-module-azure-container-app` provisions an Azure Container App Environment and a Container App as a reusable building block for EPIC-managed Azure infrastructure.

It runs a containerized service (a web API, worker, etc.) with a user-assigned managed identity for registry pulls and Key Vault secret access — no admin credentials. Secrets are sourced from Key Vault by reference and surfaced to the container as secret-backed environment variables.

---

## Resources Created

- `azurerm_container_app_environment`
- `azurerm_container_app`

The managed identity, registry, Key Vault, and workspace are **inputs** — provision them with the `azure-user-assigned-identity`, `azure-container-registry`, `azure-key-vault`, and `azure-log-analytics` modules and pass their IDs in.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Resource group name. |
| `azure_region` | `string` | Azure region. |
| `tags` | `map(string)` | Resource tags. |
| `environment_name` | `string` | Name of the Container App Environment. |
| `log_analytics_workspace_id` | `string` | Workspace ID the environment logs to. |
| `container_app_name` | `string` | Name of the Container App. |
| `user_assigned_identity_id` | `string` | Identity used for registry pulls and Key Vault access. |
| `image` | `string` | Fully-qualified container image. |

### Optional (selected)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `infrastructure_subnet_id` | `string` | `null` | Delegated subnet to VNet-inject the environment into. |
| `internal_load_balancer_enabled` | `bool` | `false` | Use an internal (private) load balancer. Requires `infrastructure_subnet_id`. |
| `revision_mode` | `string` | `Single` | `Single` or `Multiple`. |
| `registry_server` | `string` | `null` | Registry login server; `null` omits the registry block. |
| `secrets` | `list(object({ name, key_vault_secret_id }))` | `[]` | Key Vault-backed secrets (versionless IDs). |
| `container_name` | `string` | `app` | Container name. |
| `cpu` | `number` | `0.5` | CPU cores. |
| `memory` | `string` | `1Gi` | Memory. |
| `min_replicas` / `max_replicas` | `number` | `1` / `3` | Scaling bounds. |
| `env` | `list(object({ name, value, secret_name }))` | `[]` | Env vars; set `secret_name` for secret-backed vars, else `value`. |
| `ingress_external_enabled` | `bool` | `true` | Expose ingress outside the environment. |
| `target_port` | `number` | `8080` | Container listen port. |
| `ingress_transport` | `string` | `auto` | `auto`, `http`, `http2`, or `tcp`. |

---

## Outputs

| Name | Description |
|------|-------------|
| `environment_id` | Resource ID of the environment. |
| `environment_static_ip_address` | Static IP — use in a PostgreSQL firewall rule so the app can reach the DB. |
| `environment_default_domain` | Default domain suffix. |
| `container_app_id` | Resource ID of the Container App. |
| `container_app_name` | Name of the Container App. |
| `ingress_fqdn` | Ingress FQDN — wire into an App Gateway backend pool or DNS. |
| `latest_revision_fqdn` | FQDN of the latest revision. |

---

## Usage in a Terraform Project

```hcl
module "container_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-container-app.git?ref=main"

  resource_group_name        = "rg-my-app-dev"
  azure_region               = "westus2"
  environment_name           = "my-app-env"
  container_app_name         = "my-app-backend"
  log_analytics_workspace_id = module.log_analytics.workspace_id
  user_assigned_identity_id  = module.app_identity.identity_id
  registry_server            = module.acr.login_server
  image                      = "${module.acr.login_server}/backend:${var.image_tag}"
  target_port                = 8080

  secrets = [
    { name = "db-connection-string", key_vault_secret_id = module.key_vault.secret_uris["db-connection-string"] },
    { name = "cookie-secret",        key_vault_secret_id = module.key_vault.secret_uris["cookie-secret"] },
  ]

  env = [
    { name = "NODE_ENV",             value = "staging" },
    { name = "API_PG_CONNECTION",    secret_name = "db-connection-string" },
    { name = "API_COOKIE_SECRET",    secret_name = "cookie-secret" },
  ]

  tags = module.tags.tags
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- **RBAC timing.** The identity's `AcrPull` and `Key Vault Secrets User` role assignments must exist and propagate *before* this app is created, or the first revision fails to pull the image / read secrets. RBAC is eventually consistent — in the consuming root module add a `time_sleep` (≈60-90s) that depends on the role assignments, and make this module's inputs depend on it (e.g. via `depends_on` on the module block). The `azure-user-assigned-identity` module creates the assignments; the sequencing is the root module's responsibility.
- **Secret env vars.** An `env` entry with `secret_name` set must reference a `secrets[].name` declared on the same app; `value` is left null for those. Mixing `value` and `secret_name` on one entry is invalid — pick one.
- **DB reachability.** Expose `environment_static_ip_address` into a PostgreSQL Flexible Server firewall rule (start = end = static IP) so the app can connect when the DB uses public networking. When both are VNet-injected, prefer a delegated subnet + private DNS instead (SECURITY-05 intent).
- The module sets `ingress_transport = "auto"` by default; set `http` explicitly when an upstream Application Gateway probes a fixed scheme.
