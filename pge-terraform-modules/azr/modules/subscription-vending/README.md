<!-- BEGIN_TF_DOCS -->
# Azure Subscription Vending module.
Terraform module which creates Azure Subscription using Subscription Alias API.

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
| [azapi_resource.subscription](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado_project"></a> [ado\_project](#input\_ado\_project) | Azure DevOps project name for tagging | `string` | `""` | no |
| <a name="input_billing_scope"></a> [billing\_scope](#input\_billing\_scope) | EA enrollment account billing scope - Format: /providers/Microsoft.Billing/billingAccounts/{enrollmentId}/enrollmentAccounts/{accountId} | `string` | n/a | yes |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | Management group ID for subscription placement | `string` | n/a | yes |
| <a name="input_partner_config"></a> [partner\_config](#input\_partner\_config) | Partner configuration from YAML | `any` | n/a | yes |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the subscription vending | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscription_details"></a> [subscription\_details](#output\_subscription\_details) | Full subscription details |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Created subscription ID |
| <a name="output_subscription_name"></a> [subscription\_name](#output\_subscription\_name) | Created subscription name |

<!-- END_TF_DOCS -->