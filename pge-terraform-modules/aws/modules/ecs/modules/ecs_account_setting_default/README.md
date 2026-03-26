<!-- BEGIN_TF_DOCS -->
# AWS ECS module
Terraform module which creates SAF2.0 ECS in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| [aws_ecs_account_setting_default.ecs_account_setting_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_account_setting_default) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_account_name"></a> [ecs\_account\_name](#input\_ecs\_account\_name) | Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights. | `string` | n/a | yes |
| <a name="input_ecs_account_setting_value"></a> [ecs\_account\_setting\_value](#input\_ecs\_account\_setting\_value) | State of the setting. Valid values are enabled and disabled. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_account_setting_default_all"></a> [ecs\_account\_setting\_default\_all](#output\_ecs\_account\_setting\_default\_all) | All attributes of the account setting. |
| <a name="output_ecs_account_setting_default_id"></a> [ecs\_account\_setting\_default\_id](#output\_ecs\_account\_setting\_default\_id) | ARN that identifies the account setting. |
| <a name="output_ecs_account_setting_default_principal_arn"></a> [ecs\_account\_setting\_default\_principal\_arn](#output\_ecs\_account\_setting\_default\_principal\_arn) | ARN that identifies the account setting. |

<!-- END_TF_DOCS -->