<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.deployment_script](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_resource_group.partner_cidr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.script_storage_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.script_storage_file_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.script_tag_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.script_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_user_assigned_identity.script_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [terraform_data.cidr_store](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aci_subnet_name"></a> [aci\_subnet\_name](#input\_aci\_subnet\_name) | Subnet name for Deployment Script (ACI) deployment (must have Microsoft.ContainerInstance/containerGroups delegation) | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_function_app_hostname"></a> [function\_app\_hostname](#input\_function\_app\_hostname) | Hostname of the Infoblox Function App (without https://) | `string` | n/a | yes |
| <a name="input_function_key"></a> [function\_key](#input\_function\_key) | Function App host key for authentication | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for Deployment Script (ACI) deployment | `string` | `"westus2"` | no |
| <a name="input_network_size"></a> [network\_size](#input\_network\_size) | VNet size: tiny (/25), small (/24), medium (/23), large (/22), giant (/21) | `string` | `"large"` | no |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name for resource naming | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region ID for Infoblox allocation (e.g., 'west-us-2', 'east-us') | `string` | n/a | yes |
| <a name="input_shared_resource_group"></a> [shared\_resource\_group](#input\_shared\_resource\_group) | Resource group where Deployment Script and storage will be created | `string` | n/a | yes |
| <a name="input_shared_subscription_id"></a> [shared\_subscription\_id](#input\_shared\_subscription\_id) | Subscription ID where the shared VNet and Function App reside | `string` | n/a | yes |
| <a name="input_shared_vnet_name"></a> [shared\_vnet\_name](#input\_shared\_vnet\_name) | Name of the shared VNet | `string` | n/a | yes |
| <a name="input_shared_vnet_resource_group"></a> [shared\_vnet\_resource\_group](#input\_shared\_vnet\_resource\_group) | Resource group containing the VNet (may differ from shared\_resource\_group) | `string` | `""` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Target subscription ID for the VNet (passed to Infoblox for tracking) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aci_id"></a> [aci\_id](#output\_aci\_id) | Resource ID of the ACI (empty when using smart-apply.sh pre-fetch) |
| <a name="output_aci_logs"></a> [aci\_logs](#output\_aci\_logs) | How to view ACI logs |
| <a name="output_aci_name"></a> [aci\_name](#output\_aci\_name) | Name pattern for ACI (actual name includes random suffix) |
| <a name="output_ado_agents_subnet_cidr"></a> [ado\_agents\_subnet\_cidr](#output\_ado\_agents\_subnet\_cidr) | Pre-calculated ADO agents subnet CIDR (equivalent to cidrsubnet(vnet\_cidr, 2, 2)) |
| <a name="output_allocated_cidr"></a> [allocated\_cidr](#output\_allocated\_cidr) | The CIDR allocated from Infoblox via Deployment Script |
| <a name="output_allocation_error"></a> [allocation\_error](#output\_allocation\_error) | Detailed error message if CIDR allocation failed |
| <a name="output_allocation_status"></a> [allocation\_status](#output\_allocation\_status) | Full status of CIDR allocation including success flag and any errors |
| <a name="output_compute_subnet_cidr"></a> [compute\_subnet\_cidr](#output\_compute\_subnet\_cidr) | Pre-calculated compute subnet CIDR (equivalent to cidrsubnet(vnet\_cidr, 2, 0)) |
| <a name="output_debug_azapi_output"></a> [debug\_azapi\_output](#output\_debug\_azapi\_output) | DEBUG: Direct azapi output object |
| <a name="output_debug_raw_output"></a> [debug\_raw\_output](#output\_debug\_raw\_output) | DEBUG: Raw output from azapi deployment script resource (JSON encoded) |
| <a name="output_debug_script_outputs_flat"></a> [debug\_script\_outputs\_flat](#output\_debug\_script\_outputs\_flat) | DEBUG: Flat format attempt |
| <a name="output_debug_script_outputs_nested"></a> [debug\_script\_outputs\_nested](#output\_debug\_script\_outputs\_nested) | DEBUG: Nested format attempt |
| <a name="output_deployment_script_id"></a> [deployment\_script\_id](#output\_deployment\_script\_id) | The Azure resource ID of the Deployment Script (for debugging) |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | The Function App URL called by the Deployment Script (without key) |
| <a name="output_is_placeholder"></a> [is\_placeholder](#output\_is\_placeholder) | Always false - Deployment Script either succeeds with real CIDR or fails |
| <a name="output_partner_cidr_rg_name"></a> [partner\_cidr\_rg\_name](#output\_partner\_cidr\_rg\_name) | Per-partner resource group in shared subscription for CIDR allocation resources |
| <a name="output_privateendpoint_subnet_cidr"></a> [privateendpoint\_subnet\_cidr](#output\_privateendpoint\_subnet\_cidr) | Pre-calculated private endpoint subnet CIDR (equivalent to cidrsubnet(vnet\_cidr, 2, 1)) |
| <a name="output_requested_size"></a> [requested\_size](#output\_requested\_size) | The CIDR size requested from Infoblox |
| <a name="output_reserved_subnet_cidr"></a> [reserved\_subnet\_cidr](#output\_reserved\_subnet\_cidr) | Pre-calculated reserved subnet CIDR (equivalent to cidrsubnet(vnet\_cidr, 2, 3)) |
| <a name="output_script_outputs"></a> [script\_outputs](#output\_script\_outputs) | Full outputs from the Deployment Script |


<!-- END_TF_DOCS -->
