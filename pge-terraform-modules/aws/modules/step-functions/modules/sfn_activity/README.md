<!-- BEGIN_TF_DOCS -->
# AWS Step Functions Activity
Terraform module which creates SAF2.0 step functions activity in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_sfn_activity.sfn_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_activity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sfn_activity_name"></a> [sfn\_activity\_name](#input\_sfn\_activity\_name) | The name of the activity to create. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfn_activity_all"></a> [sfn\_activity\_all](#output\_sfn\_activity\_all) | A map of aws sfn activity |
| <a name="output_sfn_activity_creation_date"></a> [sfn\_activity\_creation\_date](#output\_sfn\_activity\_creation\_date) | The date the activity was created. |
| <a name="output_sfn_activity_id"></a> [sfn\_activity\_id](#output\_sfn\_activity\_id) | The Amazon Resource Name (ARN) that identifies the created activity. |
| <a name="output_sfn_activity_name"></a> [sfn\_activity\_name](#output\_sfn\_activity\_name) | The name of the activity. |
| <a name="output_sfn_activity_tags_all"></a> [sfn\_activity\_tags\_all](#output\_sfn\_activity\_tags\_all) | A map of tags assigned to the resource. |


<!-- END_TF_DOCS -->