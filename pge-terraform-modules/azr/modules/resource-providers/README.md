<!-- BEGIN_TF_DOCS -->
# Azure Register Provider Module
Terraform module which registers Azure Resource Providers in a subscription using azapi

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

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
| [azapi_resource_action.register_provider](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [time_sleep.wait_for_providers](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_dns_servers"></a> [custom\_dns\_servers](#input\_custom\_dns\_servers) | Custom DNS servers for VNet configuration | `list(string)` | `[]` | no |
| <a name="input_resource_providers"></a> [resource\_providers](#input\_resource\_providers) | List of Azure resource providers to register | `list(string)` | <pre>[<br>  "Microsoft.Compute",<br>  "Microsoft.Network",<br>  "Microsoft.Storage",<br>  "Microsoft.KeyVault",<br>  "Microsoft.ManagedIdentity",<br>  "Microsoft.OperationalInsights",<br>  "Microsoft.Security",<br>  "Microsoft.Authorization",<br>  "Microsoft.Web",<br>  "Microsoft.Cache",<br>  "Microsoft.Sql",<br>  "Microsoft.DevOpsInfrastructure",<br>  "Microsoft.DevCenter"<br>]</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for provider registration | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_configuration"></a> [dns\_configuration](#output\_dns\_configuration) | DNS server configuration |
| <a name="output_provider_registration_note"></a> [provider\_registration\_note](#output\_provider\_registration\_note) | Information about how this module handles resource provider registration |
| <a name="output_registered_providers"></a> [registered\_providers](#output\_registered\_providers) | List of resource providers |


<!-- END_TF_DOCS -->