<!-- BEGIN_TF_DOCS -->

# Azure Managed Build Pool Module

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Overview

This module creates a self-hosted Azure DevOps build pool using Azure Virtual Machine Scale Sets (VMSS).

## Features

- **Auto-scaling**: Automatically scales build agents based on demand
- **Managed Identity**: Uses Azure Managed Identity for secure authentication
- **Modern OS**: Ubuntu 22.04 LTS with latest tools pre-installed
- **Networking**: Dedicated VNet and subnet for build agents
- **Security**: Network Security Group with outbound-only rules

## Architecture

```
Subscription
├── Virtual Network (10.{100+partner_index}.0.0/16)
│   ├── Build Agents Subnet (10.{100+partner_index}.2.0/24)
│   └── Network Security Group (Outbound only)
├── Virtual Machine Scale Set (VMSS)
│   ├── Linux VMs (Ubuntu 22.04)
│   ├── Managed Identity (for Azure authentication)
│   └── Custom Install Script (ADO agent registration)
└── ADO Agent Pool (organization-level)
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | ~> 1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Prerequisites

- Active Azure DevOps organization
- Azure DevOps Personal Access Token (PAT) with Agent Pools read/write permission
- Target subscription must have resource providers registered (see ado-automation parent)

## Usage

Usage information can be found in `modules/examples/*`

```hcl
module "managed_build_pool" {
  source = "./modules/managed-build-pool"

  resource_group_name    = azurerm_resource_group.ado.name
  location               = azurerm_resource_group.ado.location
  partner_name           = "acme-corp"
  partner_index          = 1

  ado_url                = "https://dev.azure.com/myorg"
  ado_pat_token          = var.ado_pat_token
  managed_identity_id    = azurerm_user_assigned_identity.build_agents.id

  build_agent_sku        = "Standard_D2s_v3"
  build_agent_instances  = 2
  build_pool_max_agents  = 5
  build_pool_desired_idle = 1

  tags = {
    environment = "production"
    partner     = "acme-corp"
  }
}
```

`cd pge-terraform-modules/azr/modules/managed-build-pool`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network.ado_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subnet.ado_agents](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_network_security_group.ado_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet_network_security_group_association.ado_nsg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_linux_virtual_machine_scale_set.build_agents](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [tls_private_key.build_agents](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azuredevops_agent_pool.pool](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/agent_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | n/a | yes |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name (used in resource naming) | `string` | n/a | yes |
| <a name="input_partner_index"></a> [partner\_index](#input\_partner\_index) | Partner index for CIDR block (0-254) | `number` | n/a | yes |
| <a name="input_ado_url"></a> [ado\_url](#input\_ado\_url) | Azure DevOps organization URL | `string` | n/a | yes |
| <a name="input_ado_pat_token"></a> [ado\_pat\_token](#input\_ado\_pat\_token) | Azure DevOps personal access token for agent registration | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Resource ID of the managed identity for build agents | `string` | n/a | yes |
| <a name="input_build_agent_sku"></a> [build\_agent\_sku](#input\_build\_agent\_sku) | Azure VM SKU for build agents | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_build_agent_instances"></a> [build\_agent\_instances](#input\_build\_agent\_instances) | Initial number of build agents | `number` | `3` | no |
| <a name="input_build_pool_max_agents"></a> [build\_pool\_max\_agents](#input\_build\_pool\_max\_agents) | Maximum number of build agents for auto-scaling | `number` | `5` | no |
| <a name="input_build_pool_desired_idle"></a> [build\_pool\_desired\_idle](#input\_build\_pool\_desired\_idle) | Desired number of idle agents to maintain | `number` | `1` | no |
| <a name="input_build_agent_image"></a> [build\_agent\_image](#input\_build\_agent\_image) | Base operating system image for build agents | `string` | `"Ubuntu-22.04"` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the virtual network (CIDR block) | `list(string)` | `["10.100.0.0/16"]` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | Address prefix for the build agents subnet | `string` | `"10.100.2.0/24"` | no |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | List of additional security rules for outbound access | `list(object)` | `[...]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | ADO Agent Pool ID |
| <a name="output_agent_pool_name"></a> [agent\_pool\_name](#output\_agent\_pool\_name) | ADO Agent Pool name |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | Virtual Machine Scale Set ID |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Virtual Network ID |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Build agents subnet ID |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | Public SSH key for connecting to agents |

## Agent Installation

The custom data script (`scripts/install-build-agent.sh`) automatically:

1. Installs system dependencies (curl, git, build-essential, etc.)
2. Installs Docker runtime
3. Installs Node.js 18
4. Installs Azure CLI
5. Downloads and extracts the ADO agent
6. Registers the agent with the ADO organization
7. Installs the agent as a systemd service

## Networking

### Virtual Network
- CIDR: `10.{100+partner_index}.0.0/16`
- Example for partner_index=1: `10.101.0.0/16`

### Subnets
- Build Agents: `10.{100+partner_index}.2.0/24`

### Network Security

The Network Security Group allows:
- ✅ Outbound HTTPS (443) to any destination (for ADO communication)
- ❌ All inbound traffic (agents are outbound-only)
- ❌ Internal traffic between subnets (not needed for basic builds)

## Monitoring

View agent logs via Azure Portal:

1. Go to Virtual Machine Scale Set → Instances
2. Connect to any instance via Bastion or RDP
3. Check service status: `sudo systemctl status azureuser-ado-agent@1`
4. View logs: `sudo journalctl -u azureuser-ado-agent@1 -f`

## Troubleshooting

### Agents not connecting to ADO
- Verify PAT token is valid and has Agent Pools permission
- Check NSG allows outbound HTTPS (443)
- Review custom data logs: `/var/log/ado-agent-setup.log`

### High CPU/Memory usage
- Increase `build_agent_sku` (e.g., Standard_D4s_v3)
- Reduce `build_pool_desired_idle` to scale down unused agents

### VMSS instances not starting
- Check Azure Portal for error messages
- Verify managed identity exists and has necessary permissions
- Ensure region supports the selected VM SKU

## Future Enhancements

- [ ] Windows Server 2022 support
- [ ] Custom build tools installation
- [ ] Agent performance monitoring
- [ ] Integration with Azure DevOps Deployment Groups
- [ ] Spot VM instances for cost optimization

## References

- [Azure DevOps Self-hosted Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser)
- [Azure Virtual Machine Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/)
- [Custom Data in VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/custom-data)

<!-- END_TF_DOCS -->
