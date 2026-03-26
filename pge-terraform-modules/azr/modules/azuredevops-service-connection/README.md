# Azure DevOps Service Connections Module

This module creates Azure DevOps service connections for:
- **Outbound**: Connection to Azure using Managed Identity (MI2)
- **Inbound**: Connection from GitHub using PAT or OAuth/GitHub App
- **Custom**: Generic service connections for other integrations

## Features

- Azure service connection with Managed Identity authentication
- GitHub service connection with PAT or OAuth authentication
- Custom generic service connections
- Optional authorization for all pipelines
- Fully parameterized and reusable

## Usage

### Azure Service Connection (Outbound to Azure)

```hcl
module "service_connections" {
  source = "./modules/azuredevops-service-connections"

  project_id = module.ado_project.project_id

  # Azure Connection using MI2
  create_azure_connection      = true
  azure_connection_name        = "Azure-Production"
  azure_connection_description = "Connection to Azure Production subscription"
  tenant_id                    = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id              = "12345678-1234-1234-1234-123456789012"
  subscription_name            = "Production Subscription"
  managed_identity_client_id   = module.ado_project.managed_identity_client_id

  authorize_all_pipelines = true
}
```

### GitHub Service Connection (Inbound from GitHub)

```hcl
module "service_connections" {
  source = "./modules/azuredevops-service-connections"

  project_id = module.ado_project.project_id

  # GitHub Connection using PAT
  create_github_connection      = true
  github_connection_name        = "GitHub-Repos"
  github_connection_description = "Connection to GitHub repositories"
  github_pat                    = var.github_personal_access_token

  authorize_all_pipelines = true
}
```

### Combined Usage

```hcl
module "service_connections" {
  source = "./modules/azuredevops-service-connections"

  project_id = module.ado_project.project_id

  # Azure Connection
  create_azure_connection      = true
  azure_connection_name        = "Azure-Production"
  tenant_id                    = var.tenant_id
  subscription_id              = var.subscription_id
  subscription_name            = var.subscription_name
  managed_identity_client_id   = module.ado_project.managed_identity_client_id

  # GitHub Connection
  create_github_connection = true
  github_connection_name   = "GitHub-Main"
  github_pat               = var.github_pat

  authorize_all_pipelines = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | Azure DevOps project ID | string | - | yes |
| authorize_all_pipelines | Authorize all pipelines | bool | false | no |
| create_azure_connection | Create Azure connection | bool | true | no |
| azure_connection_name | Azure connection name | string | "Azure-Connection-MI" | no |
| tenant_id | Azure AD tenant ID | string | - | yes (if Azure) |
| subscription_id | Azure subscription ID | string | - | yes (if Azure) |
| subscription_name | Azure subscription name | string | - | yes (if Azure) |
| managed_identity_client_id | MI2 client ID | string | "" | yes (if Azure) |
| create_github_connection | Create GitHub PAT connection | bool | false | no |
| github_connection_name | GitHub connection name | string | "GitHub-Connection" | no |
| github_pat | GitHub PAT (sensitive) | string | "" | yes (if GitHub) |

## Outputs

| Name | Description |
|------|-------------|
| azure_connection_id | Azure service connection ID |
| azure_connection_name | Azure service connection name |
| github_connection_id | GitHub service connection ID |
| github_connection_name | GitHub service connection name |

## Requirements

- Terraform >= 1.0
- azuredevops provider ~> 1.0

## Notes

- For GitHub connections, PAT requires appropriate scopes (repo, admin:repo_hook)
- Managed Identity must have proper Azure RBAC permissions before creating service connection
- Consider using GitHub App authentication for enhanced security

<!-- BEGIN_TF_DOCS -->
# Azure DevOps Service Connections Module
Terraform module which creates SAF2.0 ADO service connection for Partner subscription (using MI2) and GitHub (using OIDC or PAT)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | ~> 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.federated_credential](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azuredevops_pipeline_authorization.azure_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.custom_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.github_app_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.github_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.jfrog_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.sonarqube_connection_auth](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_serviceendpoint_azurerm.azure_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm) | resource |
| [azuredevops_serviceendpoint_generic.custom_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_generic) | resource |
| [azuredevops_serviceendpoint_generic.jfrog_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_generic) | resource |
| [azuredevops_serviceendpoint_github.github_app_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_github) | resource |
| [azuredevops_serviceendpoint_github.github_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_github) | resource |
| [azuredevops_serviceendpoint_sonarqube.sonarqube_connection](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_sonarqube) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorize_all_pipelines"></a> [authorize\_all\_pipelines](#input\_authorize\_all\_pipelines) | Authorize all pipelines to use the service connections | `bool` | `false` | no |
| <a name="input_authorize_all_repos"></a> [authorize\_all\_repos](#input\_authorize\_all\_repos) | Grant service connection access to all repositories in the GitHub organization | `bool` | `false` | no |
| <a name="input_azure_connection_description"></a> [azure\_connection\_description](#input\_azure\_connection\_description) | Description of the Azure service connection | `string` | `"Service connection to Azure using Managed Identity"` | no |
| <a name="input_azure_connection_name"></a> [azure\_connection\_name](#input\_azure\_connection\_name) | Name of the Azure service connection | `string` | `"Azure-Connection-MI"` | no |
| <a name="input_create_azure_connection"></a> [create\_azure\_connection](#input\_create\_azure\_connection) | Create Azure service connection using managed identity (temporarily disabled due to OIDC configuration issue) | `bool` | `false` | no |
| <a name="input_create_federated_credential"></a> [create\_federated\_credential](#input\_create\_federated\_credential) | Whether to create the federated credential (set to true explicitly, not based on computed values) | `bool` | `true` | no |
| <a name="input_create_github_app_connection"></a> [create\_github\_app\_connection](#input\_create\_github\_app\_connection) | Create GitHub service connection using OAuth/GitHub App | `bool` | `false` | no |
| <a name="input_create_github_connection"></a> [create\_github\_connection](#input\_create\_github\_connection) | Create GitHub service connection using PAT | `bool` | `false` | no |
| <a name="input_create_github_oidc"></a> [create\_github\_oidc](#input\_create\_github\_oidc) | Use GitHub OIDC (OAuth) instead of PAT for secure connection | `bool` | `true` | no |
| <a name="input_create_jfrog_connection"></a> [create\_jfrog\_connection](#input\_create\_jfrog\_connection) | Create JFrog Artifactory service connection for artifact management | `bool` | `false` | no |
| <a name="input_create_sonarqube_connection"></a> [create\_sonarqube\_connection](#input\_create\_sonarqube\_connection) | Create SonarQube service connection for code quality analysis | `bool` | `false` | no |
| <a name="input_custom_service_connections"></a> [custom\_service\_connections](#input\_custom\_service\_connections) | Map of custom service connections to create | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    server_url  = string<br/>    username    = string<br/>    password    = string<br/>  }))</pre> | `{}` | no |
| <a name="input_github_app_connection_description"></a> [github\_app\_connection\_description](#input\_github\_app\_connection\_description) | Description of the GitHub App service connection | `string` | `"Service connection to GitHub using OAuth"` | no |
| <a name="input_github_app_connection_name"></a> [github\_app\_connection\_name](#input\_github\_app\_connection\_name) | Name of the GitHub App service connection | `string` | `"GitHub-App-Connection"` | no |
| <a name="input_github_connection_description"></a> [github\_connection\_description](#input\_github\_connection\_description) | Description of the GitHub service connection | `string` | `"Service connection to GitHub"` | no |
| <a name="input_github_connection_name"></a> [github\_connection\_name](#input\_github\_connection\_name) | Name of the GitHub service connection | `string` | `"GitHub-Connection"` | no |
| <a name="input_github_oauth_config_id"></a> [github\_oauth\_config\_id](#input\_github\_oauth\_config\_id) | GitHub OAuth configuration ID registered in ADO organization | `string` | `"170e544c-cae5-4f78-8a19-26a52d6502d7"` | no |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | GitHub Personal Access Token (sensitive) - deprecated, use OIDC instead | `string` | `""` | no |
| <a name="input_jfrog_access_token"></a> [jfrog\_access\_token](#input\_jfrog\_access\_token) | JFrog Artifactory access token or API key | `string` | `""` | no |
| <a name="input_jfrog_connection_name"></a> [jfrog\_connection\_name](#input\_jfrog\_connection\_name) | Name of the JFrog Artifactory service connection | `string` | `"Artifactory"` | no |
| <a name="input_jfrog_url"></a> [jfrog\_url](#input\_jfrog\_url) | JFrog Artifactory server URL | `string` | `"https://jfrog.nonprod.pge.com"` | no |
| <a name="input_jfrog_username"></a> [jfrog\_username](#input\_jfrog\_username) | JFrog Artifactory username (service account) | `string` | `""` | no |
| <a name="input_managed_identity_client_id"></a> [managed\_identity\_client\_id](#input\_managed\_identity\_client\_id) | Client ID of the managed identity (MI2) | `string` | `""` | no |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | Full resource ID of the managed identity (MI2) for creating federated credential | `string` | `""` | no |
| <a name="input_managed_identity_resource_group"></a> [managed\_identity\_resource\_group](#input\_managed\_identity\_resource\_group) | Resource group name containing the managed identity (MI2) | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the Azure DevOps project | `string` | n/a | yes |
| <a name="input_sonarqube_connection_name"></a> [sonarqube\_connection\_name](#input\_sonarqube\_connection\_name) | Name of the SonarQube service connection | `string` | `"SonarQube"` | no |
| <a name="input_sonarqube_token"></a> [sonarqube\_token](#input\_sonarqube\_token) | SonarQube authentication token (project token or user token) | `string` | `""` | no |
| <a name="input_sonarqube_url"></a> [sonarqube\_url](#input\_sonarqube\_url) | SonarQube server URL | `string` | `"https://sonarqube.nonprod.pge.com"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID (GUID only, not full resource ID) | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Azure subscription name | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_connection_federation_issuer"></a> [azure\_connection\_federation\_issuer](#output\_azure\_connection\_federation\_issuer) | Workload Identity Federation issuer URL for the Azure service connection |
| <a name="output_azure_connection_federation_subject"></a> [azure\_connection\_federation\_subject](#output\_azure\_connection\_federation\_subject) | Workload Identity Federation subject for the Azure service connection |
| <a name="output_azure_connection_id"></a> [azure\_connection\_id](#output\_azure\_connection\_id) | ID of the Azure service connection |
| <a name="output_azure_connection_name"></a> [azure\_connection\_name](#output\_azure\_connection\_name) | Name of the Azure service connection |
| <a name="output_custom_connection_ids"></a> [custom\_connection\_ids](#output\_custom\_connection\_ids) | Map of custom service connection IDs |
| <a name="output_custom_connection_names"></a> [custom\_connection\_names](#output\_custom\_connection\_names) | Map of custom service connection names |
| <a name="output_federated_credential_id"></a> [federated\_credential\_id](#output\_federated\_credential\_id) | ID of the federated identity credential created on MI2 |
| <a name="output_github_app_connection_id"></a> [github\_app\_connection\_id](#output\_github\_app\_connection\_id) | ID of the GitHub App service connection |
| <a name="output_github_app_connection_name"></a> [github\_app\_connection\_name](#output\_github\_app\_connection\_name) | Name of the GitHub App service connection |
| <a name="output_github_connection_id"></a> [github\_connection\_id](#output\_github\_connection\_id) | ID of the GitHub PAT service connection |
| <a name="output_github_connection_name"></a> [github\_connection\_name](#output\_github\_connection\_name) | Name of the GitHub PAT service connection |
| <a name="output_jfrog_connection_id"></a> [jfrog\_connection\_id](#output\_jfrog\_connection\_id) | ID of the JFrog Artifactory service connection |
| <a name="output_jfrog_connection_name"></a> [jfrog\_connection\_name](#output\_jfrog\_connection\_name) | Name of the JFrog Artifactory service connection |
| <a name="output_sonarqube_connection_id"></a> [sonarqube\_connection\_id](#output\_sonarqube\_connection\_id) | ID of the SonarQube service connection |
| <a name="output_sonarqube_connection_name"></a> [sonarqube\_connection\_name](#output\_sonarqube\_connection\_name) | Name of the SonarQube service connection |
<!-- END_TF_DOCS -->