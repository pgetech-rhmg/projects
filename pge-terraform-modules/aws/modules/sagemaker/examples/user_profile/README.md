<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker user\_profile example
# Usage example for Sagemaker user\_profile

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
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_studio_lifecycle_config"></a> [studio\_lifecycle\_config](#module\_studio\_lifecycle\_config) | ../../modules/studio_lifecycle_config | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_user_profile"></a> [user\_profile](#module\_user\_profile) | ../../modules/user_profile | n/a |
| <a name="module_user_profile_iam_role"></a> [user\_profile\_iam\_role](#module\_user\_profile\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.user_profile_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.user_profile_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.user_profile_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | The ID of the associated Domain. | `string` | n/a | yes |
| <a name="input_jupyter_server_app_settings_instance_type"></a> [jupyter\_server\_app\_settings\_instance\_type](#input\_jupyter\_server\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_kernel_gateway_app_settings_instance_type"></a> [kernel\_gateway\_app\_settings\_instance\_type](#input\_kernel\_gateway\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name for the User Profile. | `string` | n/a | yes |
| <a name="input_notebook_output_option"></a> [notebook\_output\_option](#input\_notebook\_output\_option) | Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_studio_lifecycle_config_app_type"></a> [studio\_lifecycle\_config\_app\_type](#input\_studio\_lifecycle\_config\_app\_type) | The App type that the Lifecycle Configuration is attached to. Valid values are JupyterServer and KernelGateway. | `string` | n/a | yes |
| <a name="input_studio_lifecycle_config_content"></a> [studio\_lifecycle\_config\_content](#input\_studio\_lifecycle\_config\_content) | The content of your Studio Lifecycle Configuration script. This content must be base64 encoded. | `string` | n/a | yes |
| <a name="input_tensor_board_app_settings_instance_type"></a> [tensor\_board\_app\_settings\_instance\_type](#input\_tensor\_board\_app\_settings\_instance\_type) | The instance type that the image version runs on.For valid values see SageMaker Instance Types. | `string` | n/a | yes |
| <a name="input_user_profile_role_service"></a> [user\_profile\_role\_service](#input\_user\_profile\_role\_service) | AWS service of the IAM role | `list(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_user_profile_arn"></a> [user\_profile\_arn](#output\_user\_profile\_arn) | The user profile Amazon Resource Name (ARN). |
| <a name="output_user_profile_home_efs_file_system_id"></a> [user\_profile\_home\_efs\_file\_system\_id](#output\_user\_profile\_home\_efs\_file\_system\_id) | The ID of the user's profile in the Amazon Elastic File System (EFS) volume. |
| <a name="output_user_profile_id"></a> [user\_profile\_id](#output\_user\_profile\_id) | The user profile Amazon Resource Name (ARN). |

<!-- END_TF_DOCS -->