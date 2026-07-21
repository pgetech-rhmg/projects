# EPIC Azure Entra App Registration Module

## Overview

`epic-pipeline-module-azure-entra-app` provisions a Microsoft Entra ID (Azure AD) application registration, its service principal, and a rotating client secret, as a reusable building block for EPIC-managed Azure infrastructure.

It is used by workloads that call Microsoft Graph or act as an OIDC relying party — for example an identity-management API that creates users and manages group membership in an Entra tenant. Graph permissions are declared by **name** (`User.Read`, `Group.ReadWrite.All`, …); the module resolves the GUIDs, so callers never hardcode permission IDs.

This is the one Azure module in the EPIC library that uses the **`azuread`** provider rather than `azurerm`.

---

## Resources Created

- `azuread_application`
- `azuread_service_principal`
- `azuread_application_password` (rotating client secret)
- `time_rotating` (drives secret rotation)

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `display_name` | `string` | Display name of the application registration. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sign_in_audience` | `string` | `AzureADMyOrg` | Which accounts can sign in. |
| `redirect_uris` | `list(string)` | `[]` | Web redirect URIs. |
| `enable_id_token_issuance` | `bool` | `true` | Enable implicit-grant ID tokens. |
| `enable_access_token_issuance` | `bool` | `false` | Enable implicit-grant access tokens. |
| `graph_delegated_permissions` | `list(string)` | `[]` | Graph delegated (scope) permission names. |
| `graph_application_permissions` | `list(string)` | `[]` | Graph application (role) permission names. Require admin consent. |
| `app_role_assignment_required` | `bool` | `false` | Require an app-role assignment before sign-in. |
| `secret_display_name` | `string` | `epic-managed-secret` | Display name for the client secret. |
| `secret_rotation_days` | `number` | `180` | Rotate the client secret after this many days. |
| `application_tags` | `list(string)` | `[]` | Tags on the app registration (list of strings, not a key/value map). |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `application_id` | No | Object ID of the application registration. |
| `client_id` | No | Client (application) ID. |
| `service_principal_id` | No | Object ID of the service principal. |
| `service_principal_object_id` | No | SP object ID (for role assignments / group ownership). |
| `client_secret` | Yes | Generated client secret — write to Key Vault. |
| `tenant_id` | No | Tenant ID the app is registered in. |

---

## Usage in a Terraform Project

```hcl
module "entra_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-entra-app.git?ref=main"

  display_name  = "my-app-registration"
  redirect_uris = ["https://my-app.example.com/auth/callback"]

  graph_delegated_permissions   = ["User.Read", "openid", "profile", "email"]
  graph_application_permissions  = ["User.ReadWrite.All", "Group.ReadWrite.All", "GroupMember.ReadWrite.All"]

  application_tags = ["epic", "my-app"]
}

# Store the secret in Key Vault rather than passing it around in plaintext.
module "key_vault" {
  # ...
  secrets = {
    "graph-client-secret" = module.entra_app.client_secret
  }
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azuread` | `~> 3.0` |
| `hashicorp/time` | `~> 0.9` |

---

## Notes

- **Provider config is the caller's responsibility.** The consuming root module must configure the `azuread` provider (tenant). For the VEG onboarding workload this is the *external* PGE EXT Dir tenant, which is distinct from the `azurerm` subscription tenant — configure `azuread` explicitly rather than relying on the ambient CLI context.
- **Application permissions require admin consent.** Terraform grants the permission but cannot consent to it; an Entra admin must grant tenant-wide consent (or run `az ad app permission admin-consent`) before Graph application calls succeed.
- The client secret **rotates** every `secret_rotation_days` via `time_rotating` + `rotate_when_changed`. On rotation a new secret value is generated — ensure the consumer re-reads it from Key Vault rather than caching it. This replaces the fixed one-year `timeadd`/`ignore_changes` pattern with real rotation (SECURITY-10 control intent).
- Graph permission names are resolved from the tenant's Microsoft Graph service principal. An unknown/misspelled permission name fails at plan with a key-lookup error — that is the intended guardrail.
