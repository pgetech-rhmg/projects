<!-- BEGIN_TF_DOCS -->
# AWS AppConfig module
Terraform module which creates SAF2.0 AppConfig deployment strategy in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_deployment_strategy.pge_strategy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bake_time"></a> [bake\_time](#input\_bake\_time) | Amount of time AppConfig monitors for alarms before consdiering the deployment complete and no longer eligble for automatic roll back. 0 <= x <= 1440 | `number` | `0` | no |
| <a name="input_deployment_duration"></a> [deployment\_duration](#input\_deployment\_duration) | The duration of the AppConfig deployment strategy. 0 <= x <= 1440 | `number` | `1` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig deployment strategy. | `string` | `"appconfig strategy desc"` | no |
| <a name="input_growth_factor"></a> [growth\_factor](#input\_growth\_factor) | Percentage of targets to receive a deployed configuration during each interval. 1 <= x <= 100 | `number` | `100` | no |
| <a name="input_growth_type"></a> [growth\_type](#input\_growth\_type) | Algorithm used to define how percentage grows over time. Either LINEAR or EXPONENTIAL. Default LINEAR | `string` | `"LINEAR"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AppConfig deployment strategy. | `string` | `"appconfig strategy name"` | no |
| <a name="input_replicate_to"></a> [replicate\_to](#input\_replicate\_to) | Where to save the deployment strategy. Either NONE or SSM\_DOCUMENT | `string` | `"NONE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the APpConfig Deployment Strategy |
| <a name="output_id"></a> [id](#output\_id) | AppConfig Deployment Strategy ID |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of all tags assigned to the resource. |

<!-- END_TF_DOCS -->