<!-- BEGIN_TF_DOCS -->

# Azure Observability Module

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Overview

This Terraform module creates an Azure Log Analytics Workspace for centralized logging and monitoring of Azure resources. The module provisions a Log Analytics Workspace using the Azure API (azapi) provider, enabling collection and analysis of logs and metrics from various Azure resources.

## Features

- Creates a Log Analytics Workspace with configurable retention
- Uses the `PerGB2018` pricing tier
- Supports custom tagging
- Outputs workspace credentials for integration with other services

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |

## Usage

Usage information can be found in `modules/examples/*`

```hcl
module "observability" {
  source = "./modules/observability"

  partner_name        = "mypartner"
  partner_config      = {
    environment = "prod"
  }
  resource_group_name = "rg-mypartner-prod"
  location            = "westus2"
  subscription_id     = "00000000-0000-0000-0000-000000000000"
  retention_days      = 30

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

`cd pge-terraform-modules/azr/modules/observability`

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
| [azapi_resource.law](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name | `string` | n/a | yes |
| <a name="input_partner_config"></a> [partner\_config](#input\_partner\_config) | Partner configuration from YAML (must include `environment` key) | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Log retention in days | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | Log Analytics Workspace resource ID |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Log Analytics Workspace name |
| <a name="output_log_analytics_workspace_primary_key"></a> [log\_analytics\_workspace\_primary\_key](#output\_log\_analytics\_workspace\_primary\_key) | Log Analytics Workspace primary shared key (sensitive) |
| <a name="output_log_analytics_workspace_workspace_id"></a> [log\_analytics\_workspace\_workspace\_id](#output\_log\_analytics\_workspace\_workspace\_id) | Log Analytics Workspace ID (customer ID) |
| <a name="output_enabled_solutions"></a> [enabled\_solutions](#output\_enabled\_solutions) | Enabled Log Analytics solutions |

## Resource Naming

The Log Analytics Workspace is named using the following convention:

```
law-{partner_name}-{environment}
```

## Supported Solutions

The following Log Analytics solutions can be enabled via Azure Portal or additional configuration:

- SecurityInsights
- ContainerInsights
- VMInsights
- AzureActivity
- ChangeTracking
- Updates
- Security

<!-- END_TF_DOCS -->
