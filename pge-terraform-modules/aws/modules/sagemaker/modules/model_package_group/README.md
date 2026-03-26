<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates model\_package\_group

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_sagemaker_model_package_group.model_package_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model_package_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model_package_group_description"></a> [model\_package\_group\_description](#input\_model\_package\_group\_description) | A description for the model group. | `string` | `null` | no |
| <a name="input_model_package_group_name"></a> [model\_package\_group\_name](#input\_model\_package\_group\_name) | The name of the model group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_model_package_group_arn"></a> [model\_package\_group\_arn](#output\_model\_package\_group\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Model Package Group. |
| <a name="output_model_package_group_id"></a> [model\_package\_group\_id](#output\_model\_package\_group\_id) | The name of the Model Package Group. |
| <a name="output_sagemaker_model_package_group_all"></a> [sagemaker\_model\_package\_group\_all](#output\_sagemaker\_model\_package\_group\_all) | A map of aws sagemaker model package group |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->