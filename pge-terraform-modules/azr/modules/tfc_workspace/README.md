<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.53 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.62.1 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | 0.74.1 |

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
| [tfe_team.user_team](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team) | resource |
| [tfe_team_access.admin_access](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) | resource |
| [tfe_team_access.read_access](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) | resource |
| [tfe_team_access.user_team_access](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) | resource |
| [tfe_team_access.workspace_access](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) | resource |
| [tfe_team_member.user_member](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_member) | resource |
| [tfe_variable.ado_automation_workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.app_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.arm_use_oidc](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.azuredevops_org_url](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.azuredevops_pat_env](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.azuredevops_personal_access_token](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.compute_resource_group_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.config_directory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.data_resource_group_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.environment](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.github_org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.github_repository](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.github_service_connection_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.managed_identity_client_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.managed_identity_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.managed_identity_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.managed_identity_principal_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.network_resource_group_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.partner_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.partner_subscription_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.resource_group_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.tfc_organization](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.vnet_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_workspace.partner_workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |
| [tfe_workspace_settings.partner_workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_settings) | resource |
| [tfe_workspace_variable_set.ado_secrets_variable_set](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_variable_set) | resource |
| [tfe_workspace_variable_set.oidc_variable_set](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_variable_set) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [tfe_team.admin_teams](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/team) | data source |
| [tfe_team.read_teams](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/team) | data source |
| [tfe_team.workspace_team](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/team) | data source |
| [tfe_variable_set.ado_secrets_variable_set](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/variable_set) | data source |
| [tfe_variable_set.oidc_variable_set](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/variable_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_team_names"></a> [admin\_team\_names](#input\_admin\_team\_names) | List of TFC team names to grant admin access to the workspace | `list(string)` | `[]` | no |
| <a name="input_ado_automation_workspace"></a> [ado\_automation\_workspace](#input\_ado\_automation\_workspace) | TFC workspace name for ado-automation (WS2) - used by WS3 to reference WS2 outputs | `string` | `"azure-lz-partner-subsB-01"` | no |
| <a name="input_ado_secrets_variable_set_id"></a> [ado\_secrets\_variable\_set\_id](#input\_ado\_secrets\_variable\_set\_id) | Optional TFC variable set ID that contains shared Azure DevOps secrets (e.g., AZDO\_PERSONAL\_ACCESS\_TOKEN) | `string` | `""` | no |
| <a name="input_ado_secrets_variable_set_name"></a> [ado\_secrets\_variable\_set\_name](#input\_ado\_secrets\_variable\_set\_name) | Optional TFC variable set name that contains shared Azure DevOps secrets (alternative to ID) | `string` | `""` | no |
| <a name="input_azr_automation_workspace"></a> [azr\_automation\_workspace](#input\_azr\_automation\_workspace) | TFC workspace name for azr-automation (WS1) - used by WS3 to reference WS1 outputs (optional) | `string` | `"azr-automation"` | no |
| <a name="input_azuredevops_org_url"></a> [azuredevops\_org\_url](#input\_azuredevops\_org\_url) | Azure DevOps organization URL | `string` | n/a | yes |
| <a name="input_azuredevops_pat"></a> [azuredevops\_pat](#input\_azuredevops\_pat) | Azure DevOps Personal Access Token to inject into WS3 for azuredevops provider authentication (optional) | `string` | `""` | no |
| <a name="input_compute_resource_group_name"></a> [compute\_resource\_group\_name](#input\_compute\_resource\_group\_name) | Desired resource group name for WS3 compute/app resources | `string` | `""` | no |
| <a name="input_config_directory"></a> [config\_directory](#input\_config\_directory) | Directory containing partner YAML config files (passed from WS1 to WS3) | `string` | `"../../subscription-manifests/ps01"` | no |
| <a name="input_data_resource_group_name"></a> [data\_resource\_group\_name](#input\_data\_resource\_group\_name) | Desired resource group name for WS3 data resources | `string` | `""` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | GitHub branch for VCS integration | `string` | `"main"` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub organization name | `string` | n/a | yes |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | GitHub Personal Access Token | `string` | `""` | no |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name | `string` | n/a | yes |
| <a name="input_github_service_connection_id"></a> [github\_service\_connection\_id](#input\_github\_service\_connection\_id) | GitHub service connection ID from WS2 (ado-automation) | `string` | n/a | yes |
| <a name="input_managed_identity_client_id"></a> [managed\_identity\_client\_id](#input\_managed\_identity\_client\_id) | Managed Identity client ID for authentication | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Managed Identity resource ID for attaching to App Service | `string` | n/a | yes |
| <a name="input_managed_identity_name"></a> [managed\_identity\_name](#input\_managed\_identity\_name) | Managed Identity name | `string` | n/a | yes |
| <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id) | Managed Identity principal ID (Object ID) for RBAC assignments | `string` | n/a | yes |
| <a name="input_network_resource_group_name"></a> [network\_resource\_group\_name](#input\_network\_resource\_group\_name) | Resource group name containing WS1 network resources | `string` | `""` | no |
| <a name="input_oauth_token_id"></a> [oauth\_token\_id](#input\_oauth\_token\_id) | OAuth Token ID for VCS connection (from variable set) | `string` | `""` | no |
| <a name="input_partner_config"></a> [partner\_config](#input\_partner\_config) | Partner configuration from YAML | <pre>object({<br/>    environment = string<br/>  })</pre> | n/a | yes |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name | `string` | n/a | yes |
| <a name="input_partner_subscription_id"></a> [partner\_subscription\_id](#input\_partner\_subscription\_id) | Partner Azure subscription ID for child-automation | `string` | n/a | yes |
| <a name="input_read_team_names"></a> [read\_team\_names](#input\_read\_team\_names) | List of TFC team names to grant read access to the workspace | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | TFC team name to grant Run permissions on workspace | `string` | `""` | no |
| <a name="input_tfc_organization"></a> [tfc\_organization](#input\_tfc\_organization) | Terraform Cloud organization name | `string` | n/a | yes |
| <a name="input_tfc_project_id"></a> [tfc\_project\_id](#input\_tfc\_project\_id) | TFC Project ID to assign workspace to | `string` | `"prj-esd9dTmLP1BHAJAo"` | no |
| <a name="input_tfc_token"></a> [tfc\_token](#input\_tfc\_token) | Terraform Cloud API token for configuring VCS via API | `string` | `""` | no |
| <a name="input_tfc_username"></a> [tfc\_username](#input\_tfc\_username) | TFC username for team membership (if different from email) | `string` | `""` | no |
| <a name="input_tfc_variable_set_id"></a> [tfc\_variable\_set\_id](#input\_tfc\_variable\_set\_id) | TFC variable set ID to apply to the workspace for OIDC authentication | `string` | `""` | no |
| <a name="input_tfc_variable_set_name"></a> [tfc\_variable\_set\_name](#input\_tfc\_variable\_set\_name) | TFC variable set name to apply to the workspace for OIDC authentication (alternative to ID) | `string` | `""` | no |
| <a name="input_user_email"></a> [user\_email](#input\_user\_email) | User email to grant Run permissions on workspace (e.g., avas@pge.com) | `string` | `""` | no |
| <a name="input_vcs_working_directory"></a> [vcs\_working\_directory](#input\_vcs\_working\_directory) | VCS working directory path for Terraform code | `string` | `""` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | VNet name | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | TFC workspace name | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variable_ids"></a> [variable\_ids](#output\_variable\_ids) | Map of variable names to IDs |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | TFC workspace ID |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | TFC workspace name |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | TFC workspace URL |

<!-- END_TF_DOCS -->