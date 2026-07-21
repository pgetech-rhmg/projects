# EPIC Azure Network Module

## Overview

`epic-pipeline-module-azure-network` provisions a virtual network with its subnets and (optionally) public IP addresses as a reusable building block for EPIC-managed Azure infrastructure.

It is the networking substrate other EPIC Azure modules build on — for example, the subnet an Application Gateway lives in, a delegated subnet for a Container App Environment or PostgreSQL Flexible Server, and the static public IP an Application Gateway v2 fronts.

---

## Resources Created

- `azurerm_virtual_network`
- `azurerm_subnet` (zero or more, driven by `subnets`)
- `azurerm_public_ip` (zero or more, driven by `public_ips`)

No NSGs, route tables, or private DNS zones are created — compose those alongside this module when the workload requires them.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group. |
| `azure_region` | `string` | Azure region. |
| `vnet_name` | `string` | Name of the virtual network. |
| `tags` | `map(string)` | Resource tags applied to the VNet and public IPs. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `address_space` | `list(string)` | `["10.0.0.0/16"]` | Address space for the VNet. |
| `subnets` | `list(object(...))` | `[]` | Subnets to create. Each has `name`, `address_prefixes`, and optional `delegation` (`name`, `service_delegation_name`, `service_delegation_actions`). |
| `public_ips` | `list(object(...))` | `[]` | Public IPs to create. Each has `name`, `allocation_method` (default `Static`), `sku` (default `Standard`), `zones`. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `vnet_id` | No | Resource ID of the virtual network. |
| `vnet_name` | No | Name of the virtual network. |
| `subnet_ids` | No | Map of subnet name => subnet resource ID. |
| `public_ip_ids` | No | Map of public IP name => resource ID. |
| `public_ip_addresses` | No | Map of public IP name => allocated IP address. |

---

## Usage in a Terraform Project

```hcl
module "network" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-network.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  vnet_name           = "my-app-vnet"
  address_space       = ["10.0.0.0/16"]

  subnets = [
    { name = "appgw-subnet", address_prefixes = ["10.0.1.0/24"] },
    {
      name             = "containerapp-subnet"
      address_prefixes = ["10.0.2.0/23"]
      delegation = {
        name                       = "containerapp"
        service_delegation_name    = "Microsoft.App/environments"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    },
  ]

  public_ips = [
    { name = "appgw-pip" },
  ]

  tags = module.tags.tags
}
```

Consumers reference `module.network.subnet_ids["appgw-subnet"]` and `module.network.public_ip_ids["appgw-pip"]` when wiring the Application Gateway.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- Public IPs default to `Static` allocation and `Standard` SKU — the combination Application Gateway v2 requires. The PG&E SCP-NETWORK control intent is private-only; create public IPs only for genuinely internet-facing edges and prefer internal ingress otherwise.
- Subnet `delegation` is how a Container App Environment or PostgreSQL Flexible Server is VNet-injected. Match `service_delegation_name` to the target PaaS service.
- Address prefixes must fall within `address_space`; overlapping subnet prefixes will fail at apply.
