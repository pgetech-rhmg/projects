# EPIC Azure Container Registry Module

## Overview

`epic-pipeline-module-azure-container-registry` provisions an Azure Container Registry (ACR) as a reusable building block for EPIC-managed Azure infrastructure.

It stores the container images a Container App (or other Azure compute) runs. The module defaults to identity-based pulls — the admin user is **disabled by default** — so consumers grant `AcrPull` to a managed identity rather than distributing registry credentials.

---

## Resources Created

- `azurerm_container_registry`

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group. |
| `azure_region` | `string` | Azure region. |
| `registry_name` | `string` | Registry name. 5-50 chars, alphanumeric only, globally unique. |
| `tags` | `map(string)` | Resource tags applied to the registry. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sku` | `string` | `Standard` | Registry SKU. One of `Basic`, `Standard`, `Premium`. |
| `admin_enabled` | `bool` | `false` | Enable the admin user. Prefer managed-identity `AcrPull`; enable only when a deploy path needs registry credentials. |
| `public_network_access_enabled` | `bool` | `true` | Allow public network access. Only enforceable on the `Premium` SKU. |
| `retention_policy_days` | `number` | `null` | Untagged-manifest retention in days (Premium only). `null` disables. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `registry_id` | No | Resource ID (use as the scope for `AcrPull` role assignments). |
| `registry_name` | No | Name of the registry. |
| `login_server` | No | Login server hostname, e.g. `myregistry.azurecr.io`. |
| `admin_username` | No | Admin username, or `null` when admin is disabled. |
| `admin_password` | Yes | Admin password, or `null` when admin is disabled. |

---

## Usage in a Terraform Project

Identity-based (recommended):

```hcl
module "acr" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-container-registry.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  registry_name       = "pgemyappdevacr"

  tags = module.tags.tags
}

module "app_identity" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-user-assigned-identity.git?ref=main"
  # ...
  role_assignments = [
    { role_definition_name = "AcrPull", scope = module.acr.registry_id },
  ]
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

- **Admin user is disabled by default.** This is the SECURITY-01/-04 control intent — no shared registry credentials. If a deploy path (e.g. a script doing `docker login` with username/password) requires it, set `admin_enabled = true`; the `admin_username` / `admin_password` outputs then become non-null. The EPIC-preferred path is `az acr login` + managed-identity `AcrPull`.
- `public_network_access_enabled` and private endpoints require the `Premium` SKU. On `Basic`/`Standard` the registry is reachable publicly and the attribute is ignored — choose `Premium` where the SECURITY-05 (no-public-access) intent must be enforced.
- Registry names are globally unique and alphanumeric only (no hyphens). The module does not mutate the name — callers resolve it.
