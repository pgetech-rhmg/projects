<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates user\_profile in sagemaker domain

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| [aws_sagemaker_user_profile.user_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_image_config_name"></a> [app\_image\_config\_name](#input\_app\_image\_config\_name) | The name of the App Image Config. | `string` | `null` | no |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the associated Domain. | `string` | n/a | yes |
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | The execution role ARN for the user. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the Custom Image. | `string` | `null` | no |
| <a name="input_image_version_number"></a> [image\_version\_number](#input\_image\_version\_number) | The version number of the Custom Image. | `string` | `null` | no |
| <a name="input_jupyter_server_app_settings_instance_type"></a> [jupyter\_server\_app\_settings\_instance\_type](#input\_jupyter\_server\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | `null` | no |
| <a name="input_jupyter_server_app_settings_lifecycle_config_arn"></a> [jupyter\_server\_app\_settings\_lifecycle\_config\_arn](#input\_jupyter\_server\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | `null` | no |
| <a name="input_jupyter_server_app_settings_lifecycle_config_arns"></a> [jupyter\_server\_app\_settings\_lifecycle\_config\_arns](#input\_jupyter\_server\_app\_settings\_lifecycle\_config\_arns) | The Amazon Resource Name (ARN) of the Lifecycle Configurations. | `list(string)` | `null` | no |
| <a name="input_jupyter_server_app_settings_sagemaker_image_arn"></a> [jupyter\_server\_app\_settings\_sagemaker\_image\_arn](#input\_jupyter\_server\_app\_settings\_sagemaker\_image\_arn) | The ARN of the SageMaker image that the image version belongs to. | `string` | `null` | no |
| <a name="input_jupyter_server_app_settings_sagemaker_image_version_arn"></a> [jupyter\_server\_app\_settings\_sagemaker\_image\_version\_arn](#input\_jupyter\_server\_app\_settings\_sagemaker\_image\_version\_arn) | The ARN of the image version created on the instance. | `string` | `null` | no |
| <a name="input_kernel_gateway_app_settings_instance_type"></a> [kernel\_gateway\_app\_settings\_instance\_type](#input\_kernel\_gateway\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_kernel_gateway_app_settings_lifecycle_config_arn"></a> [kernel\_gateway\_app\_settings\_lifecycle\_config\_arn](#input\_kernel\_gateway\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | `null` | no |
| <a name="input_kernel_gateway_app_settings_lifecycle_config_arns"></a> [kernel\_gateway\_app\_settings\_lifecycle\_config\_arns](#input\_kernel\_gateway\_app\_settings\_lifecycle\_config\_arns) | The Amazon Resource Name (ARN) of the Lifecycle Configurations. | `list(string)` | `null` | no |
| <a name="input_kernel_gateway_app_settings_sagemaker_image_arn"></a> [kernel\_gateway\_app\_settings\_sagemaker\_image\_arn](#input\_kernel\_gateway\_app\_settings\_sagemaker\_image\_arn) | The ARN of the SageMaker image that the image version belongs to. | `string` | `null` | no |
| <a name="input_kernel_gateway_app_settings_sagemaker_image_version_arn"></a> [kernel\_gateway\_app\_settings\_sagemaker\_image\_version\_arn](#input\_kernel\_gateway\_app\_settings\_sagemaker\_image\_version\_arn) | The ARN of the image version created on the instance. | `string` | `null` | no |
| <a name="input_notebook_output_option"></a> [notebook\_output\_option](#input\_notebook\_output\_option) | Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled. | `string` | `"Disabled"` | no |
| <a name="input_s3_kms_key_id"></a> [s3\_kms\_key\_id](#input\_s3\_kms\_key\_id) | When notebook\_output\_option is Allowed, the AWS Key Management Service (KMS) encryption key ID used to encrypt the notebook cell output in the Amazon S3 bucket. | `string` | n/a | yes |
| <a name="input_s3_output_path"></a> [s3\_output\_path](#input\_s3\_output\_path) | When notebook\_output\_option is Allowed, the Amazon S3 bucket used to save the notebook cell output. | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security groups to be associated with the user profile. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_tensor_board_app_settings_instance_type"></a> [tensor\_board\_app\_settings\_instance\_type](#input\_tensor\_board\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_tensor_board_app_settings_lifecycle_config_arn"></a> [tensor\_board\_app\_settings\_lifecycle\_config\_arn](#input\_tensor\_board\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | `null` | no |
| <a name="input_tensor_board_app_settings_sagemaker_image_arn"></a> [tensor\_board\_app\_settings\_sagemaker\_image\_arn](#input\_tensor\_board\_app\_settings\_sagemaker\_image\_arn) | The ARN of the SageMaker image that the image version belongs to. | `string` | `null` | no |
| <a name="input_tensor_board_app_settings_sagemaker_image_version_arn"></a> [tensor\_board\_app\_settings\_sagemaker\_image\_version\_arn](#input\_tensor\_board\_app\_settings\_sagemaker\_image\_version\_arn) | The ARN of the image version created on the instance. | `string` | `null` | no |
| <a name="input_user_profile_name"></a> [user\_profile\_name](#input\_user\_profile\_name) | The name for the User Profile. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The user profile Amazon Resource Name (ARN). |
| <a name="output_home_efs_file_system_id"></a> [home\_efs\_file\_system\_id](#output\_home\_efs\_file\_system\_id) | The ID of the user's profile in the Amazon Elastic File System (EFS) volume. |
| <a name="output_id"></a> [id](#output\_id) | The user profile Amazon Resource Name (ARN). |
| <a name="output_sagemaker_user_profile_all"></a> [sagemaker\_user\_profile\_all](#output\_sagemaker\_user\_profile\_all) | A map of aws sagemaker user profile |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->