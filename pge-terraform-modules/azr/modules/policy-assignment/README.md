<!-- BEGIN_TF_DOCS -->
# Azure Policy Assignment module
Terraform module which creates SAF2.0 Policy Assignments in Azure

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.63.0 |

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
| [azurerm_policy_definition.require_appid_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_subscription_policy_assignment.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.audit_vm_managed_disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.require_appid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.require_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.storage_secure_transfer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Application ID for tagging | `string` | n/a | yes |
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | Policy enforcement mode: Default or DoNotEnforce | `string` | `"Default"` | no |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of required tags | `list(string)` | <pre>[<br/>  "AppID",<br/>  "Owner",<br/>  "Environment"<br/>]</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for policy assignment scope | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_policy_definition_id"></a> [custom\_policy\_definition\_id](#output\_custom\_policy\_definition\_id) | Custom AppID policy definition ID |
| <a name="output_policy_assignment_ids"></a> [policy\_assignment\_ids](#output\_policy\_assignment\_ids) | List of policy assignment IDs |
| <a name="output_policy_assignment_names"></a> [policy\_assignment\_names](#output\_policy\_assignment\_names) | List of policy assignment names |

<!-- END_TF_DOCS -->