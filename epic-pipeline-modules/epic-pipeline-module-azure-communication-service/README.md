# EPIC Azure Communication Service Module

## Overview

`epic-pipeline-module-azure-communication-service` provisions an Azure Communication Services (ACS) resource together with an Email Communication Service and a sender domain, as a reusable building block for EPIC-managed Azure infrastructure.

It is the transactional-email backing for applications that send mail (notifications, approvals, onboarding) via ACS. By default it stands up a free Azure-managed `*.azurecomm.net` sender domain so the workload can send without owning DNS.

---

## Resources Created

- `azurerm_communication_service`
- `azurerm_email_communication_service`
- `azurerm_email_communication_service_domain`

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group. |
| `communication_service_name` | `string` | Name of the Communication Services resource. |
| `email_service_name` | `string` | Name of the Email Communication Service resource. |
| `tags` | `map(string)` | Resource tags. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `data_location` | `string` | `United States` | Geography where data is stored at rest. |
| `domain_name` | `string` | `AzureManagedDomain` | Email domain name. Use `AzureManagedDomain` for the free `*.azurecomm.net` sender. |
| `domain_management` | `string` | `AzureManaged` | How the sender domain is managed. One of `AzureManaged`, `CustomerManaged`, `CustomerManagedInExchangeOnline`. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `communication_service_id` | No | Resource ID of the Communication Services resource. |
| `communication_service_name` | No | Name of the Communication Services resource. |
| `primary_connection_string` | Yes | Primary connection string for sending. Store in Key Vault, not in app settings. |
| `email_service_id` | No | Resource ID of the Email Communication Service. |
| `email_domain_id` | No | Resource ID of the email domain. |
| `mail_from_sender_domain` | No | Sender domain — prefix a local part (e.g. `DoNotReply@`) to form the sender address. |

---

## Usage in a Terraform Project

```hcl
module "email" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-communication-service.git?ref=main"

  resource_group_name        = "rg-my-app-dev"
  communication_service_name = "my-app-acs"
  email_service_name         = "my-app-email"

  tags = module.tags.tags
}
```

The `primary_connection_string` should be written to Key Vault and referenced by the workload as a secret — do not pass it as a plaintext app setting.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- ACS and Email Communication Service are **global** resources with no `location`; `data_location` controls only where data rests. There is no `azure_region` input on this module for that reason.
- The default Azure-managed domain sends from `DoNotReply@<guid>.azurecomm.net`. For a branded sender set `domain_management = "CustomerManaged"`, use your own `domain_name`, and add the SPF/DKIM/verification DNS records out-of-band before the domain will send.
- The connection string is a credential — the SECURITY-01 control intent is Key Vault storage, never source or plaintext app settings.
