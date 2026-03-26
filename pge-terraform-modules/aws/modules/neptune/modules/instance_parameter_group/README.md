<!-- BEGIN_TF_DOCS -->
*#AWS Neptune module
*Terraform module which creates instance parameter group

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_neptune_parameter_group.instance_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_neptune_instance_parameter_group_description"></a> [neptune\_instance\_parameter\_group\_description](#input\_neptune\_instance\_parameter\_group\_description) | The description of the Neptune parameter group | `string` | `null` | no |
| <a name="input_neptune_instance_parameter_group_family"></a> [neptune\_instance\_parameter\_group\_family](#input\_neptune\_instance\_parameter\_group\_family) | The family of the Neptune parameter group | `string` | `"neptune1"` | no |
| <a name="input_neptune_instance_parameter_group_name"></a> [neptune\_instance\_parameter\_group\_name](#input\_neptune\_instance\_parameter\_group\_name) | The name of the Neptune parameter group | `string` | n/a | yes |
| <a name="input_parameter"></a> [parameter](#input\_parameter) | The parameter of the Neptune parameter group | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_neptune_instance_parameter_group_arn"></a> [neptune\_instance\_parameter\_group\_arn](#output\_neptune\_instance\_parameter\_group\_arn) | The Neptune parameter group Amazon Resource Name (ARN) |
| <a name="output_neptune_instance_parameter_group_id"></a> [neptune\_instance\_parameter\_group\_id](#output\_neptune\_instance\_parameter\_group\_id) | The Neptune parameter group name |
| <a name="output_neptune_instance_parameter_group_tags_all"></a> [neptune\_instance\_parameter\_group\_tags\_all](#output\_neptune\_instance\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_neptune_parameter_group_all"></a> [neptune\_parameter\_group\_all](#output\_neptune\_parameter\_group\_all) | A map of aws neptune parameter group |

<!-- END_TF_DOCS -->