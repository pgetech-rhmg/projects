# AWS Sagemaker Terraform module



 Terraform base module for deploying and managing Sagemaker modules () on Amazon Web Services (AWS). 



 Sagemaker Modules can be found at `Sagemaker/modules/*`



 Sagemaker Modules examples can be found at `Sagemaker/examples/*`
<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates aws\_sagemaker\_app

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

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
| [aws_sagemaker_app.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_type"></a> [app\_type](#input\_app\_type) | The type of app. Valid values are JupyterServer, KernelGateway and TensorBoard. | `string` | n/a | yes |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The domain ID. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type that the image version runs on. For valid values see 'https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html'. | `string` | `null` | no |
| <a name="input_lifecycle_config_arn"></a> [lifecycle\_config\_arn](#input\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the app. | `string` | n/a | yes |
| <a name="input_sagemaker_image_arn"></a> [sagemaker\_image\_arn](#input\_sagemaker\_image\_arn) | The ARN of the SageMaker image that the image version belongs to. | `string` | `null` | no |
| <a name="input_sagemaker_image_version_arn"></a> [sagemaker\_image\_version\_arn](#input\_sagemaker\_image\_version\_arn) | The ARN of the image version created on the instance. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_user_profile_name"></a> [user\_profile\_name](#input\_user\_profile\_name) | The user profile name. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the app. |
| <a name="output_id"></a> [id](#output\_id) | The Amazon Resource Name (ARN) of the app. |
| <a name="output_sagemaker_app_all"></a> [sagemaker\_app\_all](#output\_sagemaker\_app\_all) | A map of aws sagemaker app |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->