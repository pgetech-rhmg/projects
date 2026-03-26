<!-- BEGIN_TF_DOCS -->
# PG&E Entra Group Assignment Module
 Terraform base module to assign Azure RBAC roles to Entra groups at subscription scope

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.read_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.read_write](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_read_only_groups"></a> [read\_only\_groups](#input\_read\_only\_groups) | List of Azure AD group object IDs for Reader access | `list(string)` | `[]` | no |
| <a name="input_read_write_groups"></a> [read\_write\_groups](#input\_read\_write\_groups) | List of Azure AD group object IDs for Contributor access | `list(string)` | `[]` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Target subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Reserved for future taggable resources and/or downstream metadata; currently not applied to any Azure resources created by this module | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_tags"></a> [module\_tags](#output\_module\_tags) | Standardized tag map including workspace and team metadata. |
| <a name="output_workspace_info"></a> [workspace\_info](#output\_workspace\_info) | Metadata about the Terraform Cloud workspace used by this module. |

<!-- END_TF_DOCS -->