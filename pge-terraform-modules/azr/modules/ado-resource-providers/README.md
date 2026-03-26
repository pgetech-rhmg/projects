<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.8.0 |

## Usage

This module is intended to be consumed from your own Terraform configuration. For example, add a `module` block that sources `azr/modules/resource-providers` and provides the required inputs, then run the usual Terraform workflow (`terraform init`, `terraform validate`, `terraform plan`, `terraform apply`) from your configuration directory.
Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource_action.register_providers](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_registered_providers"></a> [registered\_providers](#output\_registered\_providers) | List of registered resource providers |

<!-- END_TF_DOCS -->
