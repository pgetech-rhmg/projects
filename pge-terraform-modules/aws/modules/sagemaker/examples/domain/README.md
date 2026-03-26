<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker domain service example
# The terraform usage example creates Sagemaker domain service
# Only 1 sagemaker domain can be created in an account/region, for more info 'https://docs.aws.amazon.com/general/latest/gr/sagemaker.html#limits_sagemaker'

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_domain"></a> [domain](#module\_domain) | ../../modules/domain | n/a |
| <a name="module_domain_iam_role"></a> [domain\_iam\_role](#module\_domain\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.domain_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.domain_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.domain_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_default_space_execution_role"></a> [default\_space\_execution\_role](#input\_default\_space\_execution\_role) | The execution role ARN for the default space settings. If not provided, will use the default\_user\_settings execution\_role. | `string` | `null` | no |
| <a name="input_default_space_jupyter_server_app_settings_instance_type"></a> [default\_space\_jupyter\_server\_app\_settings\_instance\_type](#input\_default\_space\_jupyter\_server\_app\_settings\_instance\_type) | The instance type for JupyterServer app in default space settings. For valid values see SageMaker Instance Types. | `string` | `null` | no |
| <a name="input_default_space_kernel_gateway_app_settings_instance_type"></a> [default\_space\_kernel\_gateway\_app\_settings\_instance\_type](#input\_default\_space\_kernel\_gateway\_app\_settings\_instance\_type) | The instance type for KernelGateway app in default space settings. For valid values see SageMaker Instance Types. | `string` | `null` | no |
| <a name="input_default_space_security_groups"></a> [default\_space\_security\_groups](#input\_default\_space\_security\_groups) | The security groups for the default space settings. If not provided, will use the default\_user\_settings security\_groups. | `list(string)` | `null` | no |
| <a name="input_domain_role_service"></a> [domain\_role\_service](#input\_domain\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_home_efs_file_system"></a> [home\_efs\_file\_system](#input\_home\_efs\_file\_system) | The retention policy for data stored on an Amazon Elastic File System (EFS) volume. Valid values are Retain or Delete. Default value is Retain. | `string` | n/a | yes |
| <a name="input_jupyter_server_app_settings_instance_type"></a> [jupyter\_server\_app\_settings\_instance\_type](#input\_jupyter\_server\_app\_settings\_instance\_type) | The instance type that the image version runs on.. For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_jupyter_server_app_settings_lifecycle_config_arn"></a> [jupyter\_server\_app\_settings\_lifecycle\_config\_arn](#input\_jupyter\_server\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | n/a | yes |
| <a name="input_jupyter_server_app_settings_lifecycle_config_arns"></a> [jupyter\_server\_app\_settings\_lifecycle\_config\_arns](#input\_jupyter\_server\_app\_settings\_lifecycle\_config\_arns) | The Amazon Resource Name (ARN) of the Lifecycle Configurations. | `list(string)` | n/a | yes |
| <a name="input_kernel_gateway_app_settings_instance_type"></a> [kernel\_gateway\_app\_settings\_instance\_type](#input\_kernel\_gateway\_app\_settings\_instance\_type) | The instance type that the image version runs on.. For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_kernel_gateway_app_settings_lifecycle_config_arn"></a> [kernel\_gateway\_app\_settings\_lifecycle\_config\_arn](#input\_kernel\_gateway\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | n/a | yes |
| <a name="input_kernel_gateway_app_settings_lifecycle_config_arns"></a> [kernel\_gateway\_app\_settings\_lifecycle\_config\_arns](#input\_kernel\_gateway\_app\_settings\_lifecycle\_config\_arns) | The Amazon Resource Name (ARN) of the Lifecycle Configurations. | `list(string)` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS KMS role to assume | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the domain. | `string` | n/a | yes |
| <a name="input_notebook_output_option"></a> [notebook\_output\_option](#input\_notebook\_output\_option) | Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_tag_propagation"></a> [tag\_propagation](#input\_tag\_propagation) | Indicates whether custom tag propagation is supported for the domain. Valid values are 'ENABLED' or 'DISABLED'. | `string` | `"DISABLED"` | no |
| <a name="input_tensor_board_app_settings_instance_type"></a> [tensor\_board\_app\_settings\_instance\_type](#input\_tensor\_board\_app\_settings\_instance\_type) | The instance type that the image version runs on.. For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_tensor_board_app_settings_lifecycle_config_arn"></a> [tensor\_board\_app\_settings\_lifecycle\_config\_arn](#input\_tensor\_board\_app\_settings\_lifecycle\_config\_arn) | The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Domain. |
| <a name="output_domain_home_efs_file_system_id"></a> [domain\_home\_efs\_file\_system\_id](#output\_domain\_home\_efs\_file\_system\_id) | The ID of the Amazon Elastic File System (EFS) managed by this Domain. |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The ID of the Domain. |
| <a name="output_domain_single_sign_on_managed_application_instance_id"></a> [domain\_single\_sign\_on\_managed\_application\_instance\_id](#output\_domain\_single\_sign\_on\_managed\_application\_instance\_id) | The SSO managed application instance ID. |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | The domain's URL. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->