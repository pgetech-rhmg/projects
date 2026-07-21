# EPIC Azure User-Assigned Identity Module

## Overview

`epic-pipeline-module-azure-user-assigned-identity` provisions an Azure user-assigned managed identity and (optionally) a set of scoped RBAC role assignments for it.

It exists so workloads — most notably a Container App pulling from ACR and reading secrets from Key Vault — can authenticate to other Azure resources without any stored credential. Callers grant only the roles the workload needs, keeping the identity least-privilege by construction (SECURITY-04 control intent).

---

## Resources Created

- `azurerm_user_assigned_identity`
- `azurerm_role_assignment` (zero or more, driven by `role_assignments`)

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group the identity is created in. |
| `azure_region` | `string` | Azure region for the identity. |
| `identity_name` | `string` | Name of the user-assigned managed identity. |
| `tags` | `map(string)` | Resource tags applied to the identity. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `role_assignments` | `list(object({ role_definition_name = string, scope = string }))` | `[]` | Scoped RBAC roles granted to the identity. Keep to least privilege. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `identity_id` | No | Resource ID of the identity (assign to Container App / other compute). |
| `identity_name` | No | Name of the identity. |
| `principal_id` | No | Principal (object) ID — used when other modules assign roles to this identity. |
| `client_id` | No | Client ID — used by workloads for managed-identity auth. |

---

## Usage in a Terraform Project

```hcl
module "app_identity" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-user-assigned-identity.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  identity_name       = "my-app-container-identity"

  role_assignments = [
    { role_definition_name = "AcrPull",               scope = module.acr.registry_id },
    { role_definition_name = "Key Vault Secrets User", scope = module.key_vault.key_vault_id },
  ]

  tags = module.tags.tags
}
```

The identity's `identity_id` is then passed to the Container App module, and its `principal_id` is what the role assignments above bind to.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- Role assignments are keyed by `"<role>-<scope>"`, so the same role on two different scopes (or two roles on one scope) coexist without collision.
- RBAC propagation is eventually consistent. Consumers that immediately use the identity (e.g. a Container App pulling an image at create time) may need a `time_sleep` between the role assignment and the dependent resource — the Container App module documents this.
- Prefer this over admin credentials for ACR pulls and Key Vault reads. Do not grant broad roles (`Owner`, `Contributor`) — scope tightly to the target resource.
