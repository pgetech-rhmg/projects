<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.9.0 |
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.15.0 |

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
| [azapi_resource.managed_pool](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azuredevops_agent_pool.managed_pool](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/agent_pool) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado_org_url"></a> [ado\_org\_url](#input\_ado\_org\_url) | Azure DevOps organization URL (e.g., https://dev.azure.com/myorg) | `string` | n/a | yes |
| <a name="input_ado_project_names"></a> [ado\_project\_names](#input\_ado\_project\_names) | List of Azure DevOps project names that can use this pool | `list(string)` | n/a | yes |
| <a name="input_agent_image"></a> [agent\_image](#input\_agent\_image) | Well-known image name for agents (e.g., ubuntu-24.04/latest, windows-2022/latest) | `string` | `"ubuntu-24.04/latest"` | no |
| <a name="input_agent_sku"></a> [agent\_sku](#input\_agent\_sku) | Azure VM SKU for agents (e.g., Standard\_D4as\_v5, Standard\_D2s\_v5, Standard\_F2s\_v2) | `string` | `"Standard_D4as_v5"` | no |
| <a name="input_dev_center_project_id"></a> [dev\_center\_project\_id](#input\_dev\_center\_project\_id) | Resource ID of the Dev Center project for pool governance (REQUIRED by API) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the managed pool | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Resource ID of the UserAssigned managed identity (MI2) for the pool | `string` | n/a | yes |
| <a name="input_max_agents"></a> [max\_agents](#input\_max\_agents) | Maximum number of agents in the pool | `number` | `10` | no |
| <a name="input_max_parallel_jobs"></a> [max\_parallel\_jobs](#input\_max\_parallel\_jobs) | Maximum number of parallel jobs per project | `number` | `1` | no |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name of the managed DevOps pool | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource ID of the resource group where the pool will be created | `string` | n/a | yes |
| <a name="input_resource_providers_registered"></a> [resource\_providers\_registered](#input\_resource\_providers\_registered) | Dependency placeholder to ensure resource providers are registered | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for agent network connectivity (optional) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the managed pool | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ado_pool_id"></a> [ado\_pool\_id](#output\_ado\_pool\_id) | Azure DevOps pool ID (integer) for pipeline authorization |
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | Azure resource ID of the Azure Managed DevOps Pool |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | Name of the managed pool |
| <a name="output_provisioning_state"></a> [provisioning\_state](#output\_provisioning\_state) | Provisioning state of the managed pool |


<!-- END_TF_DOCS -->