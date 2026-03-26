# Azure App Service Module

This module creates an Azure Linux Web App with support for multiple runtimes and can be deployed on either public App Service Plans or isolated App Service Environments (ASE v3).

## Features

- **Multi-Runtime Support**: .NET, Python, Node.js, Java
- **Managed Identity**: SystemAssigned and UserAssigned identities
- **Application Insights**: Built-in APM integration
- **Health Checks**: Configurable health monitoring with automatic eviction
- **ASE Compatibility**: Works with App Service Environment v3
- **Connection Strings**: Support for database and service connections
- **PGE FinOps Tags**: Automatic tagging with workspace information

## Usage

### Basic Example

```hcl
module "app_service" {
  source  = "app.terraform.io/pgetech/appservice/azr"
  version = "0.1.0"

  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  app_service_name    = "myapp-prod"
  service_plan_id     = "/subscriptions/.../serverfarms/asp-prod"

  runtime         = "dotnet"
  runtime_version = "8.0"

  app_settings = {
    "ENVIRONMENT" = "production"
  }

  tags = {
    Environment = "Prod"
    AppID       = "APP-12345"
  }
}
```

### With Application Insights

```hcl
module "app_service" {
  source  = "app.terraform.io/pgetech/appservice/azr"
  version = "0.1.0"

  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  app_service_name    = "myapp-prod"
  service_plan_id     = module.app_service_plan.id

  runtime         = "python"
  runtime_version = "3.11"

  application_insights_connection_string = "InstrumentationKey=...;IngestionEndpoint=..."

  tags = {
    Environment = "Prod"
    AppID       = "APP-12345"
  }
}
```

### Java Application

```hcl
module "java_app" {
  source  = "app.terraform.io/pgetech/appservice/azr"
  version = "0.1.0"

  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  app_service_name    = "javaapp-prod"
  service_plan_id     = module.app_service_plan.id

  runtime         = "java"
  runtime_version = "17"

  connection_strings = {
    "DefaultConnection" = {
      type  = "SQLAzure"
      value = "Server=tcp:myserver.database.windows.net,1433;Database=mydb;..."
    }
  }

  app_settings = {
    "JAVA_OPTS" = "-Xms512m -Xmx1024m"
  }

  tags = {
    Environment = "Prod"
    AppID       = "APP-12345"
  }
}
```

## Supported Runtimes

This module supports the following runtime stacks with Azure App Service on Linux:

| Runtime | Supported Versions | Example `runtime_version` Values |
|---------|-------------------|----------------------------------|
| **dotnet** | 6.0, 7.0, 8.0, 9.0 | `"6.0"`, `"7.0"`, `"8.0"`, `"9.0"` |
| **python** | 3.8, 3.9, 3.10, 3.11, 3.12 | `"3.8"`, `"3.9"`, `"3.10"`, `"3.11"`, `"3.12"` |
| **nodejs** | 16 LTS, 18 LTS, 20 LTS | `"16-lts"`, `"18-lts"`, `"20-lts"` |
| **java** | 8, 11, 17, 21 | `"8"`, `"11"`, `"17"`, `"21"` (with Tomcat 10.0) |

**Note:** Node.js versions must use the `-lts` suffix format (e.g., `"18-lts"`). Java applications are configured to use Tomcat 10.0 as the Java server.

## Migration from child-workspaces

This module is migrated from `azure-lz-mgd-app-infra/terraform/child-workspaces/modules/app-service` and maintains exact compatibility with the original implementation while adding PGE FinOps tagging standards.

## Version

Current version: **0.1.0**

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## PGE FinOps Tags Configuration

All resources created by this module require PGE FinOps compliant tags. Pass these via the `tags` variable:

```hcl
tags = {
  AppID              = "APP-12345"                   # Application identifier
  Environment        = "Prod"                        # Environment (Dev/Test/QA/Prod)
  DataClassification = "Internal"                    # Data sensitivity (Public/Internal/Confidential/Restricted/Privileged/Confidential-BCSI/Restricted-BCSI)
  CRIS               = "High"                        # Risk level (High/Medium/Low)
  Notify             = "platform-team@pge.com"       # Notification email(s)
  Owner              = "john.doe@pge.com"            # Owner LANID(s)
  Compliance         = "None"                        # Compliance (SOX/HIPAA/CCPA/BCSI/None)
  Order              = "1234567"                     # Purchase order number (7-9 digits)
}
```

The module automatically merges these tags with workspace tracking information (`pge_team`, `tfc_wsname`, `tfc_wsid`) for complete SAF2.0 compliance.

## Support

For issues or questions, please contact the Cloud Center of Excellence team.

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

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
| [azurerm_linux_web_app.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_environment_id"></a> [app\_service\_environment\_id](#input\_app\_service\_environment\_id) | ID of App Service Environment (optional) | `string` | `""` | no |
| <a name="input_app_service_name"></a> [app\_service\_name](#input\_app\_service\_name) | Name of the App Service | `string` | n/a | yes |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings (environment variables) | `map(string)` | `{}` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | Application Insights connection string for APM | `string` | `""` | no |
| <a name="input_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#input\_application\_insights\_instrumentation\_key) | Application Insights instrumentation key (legacy, use connection string instead) | `string` | `""` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Connection strings for databases and services | <pre>map(object({<br/>    type  = string<br/>    value = string<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_https_only"></a> [enable\_https\_only](#input\_enable\_https\_only) | Enable HTTPS only | `bool` | `true` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path | `string` | `"/health"` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of identity (SystemAssigned, UserAssigned, or SystemAssigned,UserAssigned) | `string` | `"SystemAssigned"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region location | `string` | n/a | yes |
| <a name="input_managed_identity_ids"></a> [managed\_identity\_ids](#input\_managed\_identity\_ids) | List of managed identity IDs (for UserAssigned) | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime stack (dotnet, python, java, nodejs) | `string` | `"dotnet"` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Runtime version (e.g., 8.0, 3.11, 17, 20.0) | `string` | `"8.0"` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | ID of the App Service Plan | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_use_32_bit_worker"></a> [use\_32\_bit\_worker](#input\_use\_32\_bit\_worker) | Use 32-bit worker processes | `bool` | `false` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Custom domain verification ID |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname of the App Service |
| <a name="output_id"></a> [id](#output\_id) | ID of the App Service |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the managed identity |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | Tenant ID of the managed identity |
| <a name="output_name"></a> [name](#output\_name) | Name of the App Service |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses of the App Service |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | Possible outbound IP addresses of the App Service |
| <a name="output_url"></a> [url](#output\_url) | URL of the App Service |

<!-- END_TF_DOCS -->