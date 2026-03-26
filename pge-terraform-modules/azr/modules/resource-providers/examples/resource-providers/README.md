<!-- BEGIN_TF_DOCS -->
# Azure Register Provider Module
Terraform module example which registers Azure Resource Providers in a subscription using azapi

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

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
| <a name="module_example_resource_provider"></a> [example\_resource\_provider](#module\_example\_resource\_provider) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_providers"></a> [resource\_providers](#input\_resource\_providers) | List of Azure resource providers to register | `list(string)` | <pre>[<br>  "Microsoft.Compute",<br>  "Microsoft.Network",<br>  "Microsoft.Storage",<br>  "Microsoft.KeyVault",<br>  "Microsoft.ManagedIdentity",<br>  "Microsoft.OperationalInsights",<br>  "Microsoft.Security",<br>  "Microsoft.Authorization",<br>  "Microsoft.Web",<br>  "Microsoft.Cache",<br>  "Microsoft.Sql",<br>  "Microsoft.DevOpsInfrastructure",<br>  "Microsoft.DevCenter"<br>]</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for provider registration | `string` | n/a | yes |

## Outputs

No outputs.


<!-- END_TF_DOCS -->