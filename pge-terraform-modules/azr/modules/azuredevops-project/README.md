# Azure DevOps Project Module

This module creates an Azure DevOps project with an associated managed identity (MI2) for Azure service connections.

## Features

- Creates Azure DevOps project with customizable features
- Creates User Assigned Managed Identity (MI2) for Azure connections
- Configurable role assignments for MI2 at subscription or custom scopes
- Optional permissions for MI1 to create pipelines in the project
- Fully parameterized for reusability

## Usage

```hcl
module "ado_project" {
  source = "./modules/azuredevops-project"

  # Project Configuration
  project_name        = "MyAzureDevOpsProject"
  project_description = "Project created via Terraform automation"
  project_visibility  = "private"
  version_control     = "Git"
  work_item_template  = "Agile"

  # Managed Identity (MI2) Configuration
  managed_identity_name           = "mi-ado-project-connection"
  resource_group_name             = "rg-devops-automation"
  location                        = "eastus"
  subscription_id                 = "/subscriptions/12345678-1234-1234-1234-123456789012"
  assign_subscription_contributor = true

  # Optional: Custom role assignments for MI2
  custom_role_assignments = {
    "rg_contributor" = {
      scope     = "/subscriptions/xxx/resourceGroups/my-rg"
      role_name = "Contributor"
    }
  }

  # Optional: MI1 access for pipeline creation
  mi1_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  tags = {
    Environment = "Production"
    Team        = "DevOps"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the Azure DevOps project | string | - | yes |
| project_description | Description of the project | string | "" | no |
| project_visibility | Project visibility (private/public) | string | "private" | no |
| version_control | Version control system (Git/Tfvc) | string | "Git" | no |
| work_item_template | Work item template | string | "Agile" | no |
| managed_identity_name | Name of MI2 | string | - | yes |
| resource_group_name | Resource group for MI2 | string | - | yes |
| location | Azure region | string | - | yes |
| subscription_id | Azure subscription ID | string | - | yes |
| assign_subscription_contributor | Assign Contributor at subscription level | bool | false | no |
| custom_role_assignments | Custom role assignments for MI2 | map(object) | {} | no |
| mi1_object_id | Object ID of MI1 for pipeline permissions | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| project_id | Azure DevOps project ID |
| project_name | Azure DevOps project name |
| managed_identity_id | MI2 resource ID |
| managed_identity_principal_id | MI2 principal ID |
| managed_identity_client_id | MI2 client ID |

## Requirements

- Terraform >= 1.0
- azuredevops provider ~> 1.0
- azurerm provider ~> 3.0
- azuread provider ~> 2.0

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
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

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_group_entitlement.read_only_groups](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_entitlement) | resource |
| [azuredevops_group_entitlement.read_write_groups](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_entitlement) | resource |
| [azuredevops_group_membership.admin_group_membership](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_membership) | resource |
| [azuredevops_group_membership.global_readers](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_membership) | resource |
| [azuredevops_group_membership.read_only_groups](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_membership) | resource |
| [azuredevops_group_membership.read_write_groups](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_membership) | resource |
| [azuredevops_group_membership.readers_group_membership](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group_membership) | resource |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project) | resource |
| [azuredevops_project_permissions.admin_group_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project_permissions) | resource |
| [azuredevops_project_permissions.mi2_admin](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project_permissions) | resource |
| [azuredevops_group.contributors](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/group) | data source |
| [azuredevops_group.project_administrators](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/group) | data source |
| [azuredevops_group.project_valid_users](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/group) | data source |
| [azuredevops_group.readers](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_group_object_id"></a> [ad\_group\_object\_id](#input\_ad\_group\_object\_id) | Object ID of Azure AD group to grant team-level access to ADO project | `string` | `""` | no |
| <a name="input_admin_group_descriptor"></a> [admin\_group\_descriptor](#input\_admin\_group\_descriptor) | Azure DevOps identity descriptor for Azure AD group to grant admin permissions (e.g., from 'az devops admin group list') | `string` | `""` | no |
| <a name="input_enable_artifacts"></a> [enable\_artifacts](#input\_enable\_artifacts) | Enable Azure Artifacts feature | `string` | `"enabled"` | no |
| <a name="input_enable_boards"></a> [enable\_boards](#input\_enable\_boards) | Enable Azure Boards feature | `string` | `"enabled"` | no |
| <a name="input_enable_pipelines"></a> [enable\_pipelines](#input\_enable\_pipelines) | Enable Azure Pipelines feature | `string` | `"enabled"` | no |
| <a name="input_enable_repos"></a> [enable\_repos](#input\_enable\_repos) | Enable Azure Repos feature | `string` | `"enabled"` | no |
| <a name="input_enable_testplans"></a> [enable\_testplans](#input\_enable\_testplans) | Enable Azure Test Plans feature | `string` | `"disabled"` | no |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Full URL to GitHub repository (e.g., https://github.com/owner/repo.git) | `string` | `""` | no |
| <a name="input_managed_identity_client_id"></a> [managed\_identity\_client\_id](#input\_managed\_identity\_client\_id) | Client ID (Application ID) of the pre-created managed identity (MI2) | `string` | n/a | yes |
| <a name="input_managed_identity_descriptor"></a> [managed\_identity\_descriptor](#input\_managed\_identity\_descriptor) | Azure DevOps identity descriptor for the managed identity (required for project permissions) | `string` | `""` | no |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Resource ID of the pre-created managed identity (MI2) | `string` | n/a | yes |
| <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id) | Principal ID (Object ID) of the pre-created managed identity (MI2) | `string` | n/a | yes |
| <a name="input_mi1_object_id"></a> [mi1\_object\_id](#input\_mi1\_object\_id) | Object ID of MI1 (from subscription automation) to grant pipeline creation permissions | `string` | `""` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the Azure DevOps project | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the Azure DevOps project | `string` | n/a | yes |
| <a name="input_project_visibility"></a> [project\_visibility](#input\_project\_visibility) | Visibility of the project (private or public) | `string` | `"private"` | no |
| <a name="input_read_only_groups"></a> [read\_only\_groups](#input\_read\_only\_groups) | List of Azure AD group object IDs to grant read-only access (from YAML security.read\_only\_groups) | `list(string)` | `[]` | no |
| <a name="input_read_write_groups"></a> [read\_write\_groups](#input\_read\_write\_groups) | List of Azure AD group object IDs to grant contributor access (from YAML security.read\_write\_groups) | `list(string)` | `[]` | no |
| <a name="input_readers_group_descriptor"></a> [readers\_group\_descriptor](#input\_readers\_group\_descriptor) | Azure DevOps identity descriptor for Azure AD group to grant read-only permissions | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources | `map(string)` | `{}` | no |
| <a name="input_version_control"></a> [version\_control](#input\_version\_control) | Version control system (Git or Tfvc) | `string` | `"Git"` | no |
| <a name="input_work_item_template"></a> [work\_item\_template](#input\_work\_item\_template) | Work item template (Agile, Basic, Scrum, CMMI) | `string` | `"Agile"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | Client ID (Application ID) of the managed identity (MI2) - passed through from parent |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | Resource ID of the managed identity (MI2) - passed through from parent |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | Principal ID (Object ID) of the managed identity (MI2) - passed through from parent |
| <a name="output_pipeline_creators_group_id"></a> [pipeline\_creators\_group\_id](#output\_pipeline\_creators\_group\_id) | ID of the pipeline creators group (for MI1) - disabled due to API issues |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created Azure DevOps project |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the Azure DevOps project |
| <a name="output_project_url"></a> [project\_url](#output\_project\_url) | URL of the Azure DevOps project |


<!-- END_TF_DOCS -->