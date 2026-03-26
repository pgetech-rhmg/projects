<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
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
| <a name="module_notebook_instance"></a> [notebook\_instance](#module\_notebook\_instance) | ../../modules/notebook_instance | n/a |
| <a name="module_sagemaker_iam_role"></a> [sagemaker\_iam\_role](#module\_sagemaker\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_security_group_sagemaker"></a> [security\_group\_sagemaker](#module\_security\_group\_sagemaker) | app.terraform.io/pgetech/security-group/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_code_repository.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_code_repository) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.sagemaker_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.sagemaker_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.sagemaker_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_direct_internet_access"></a> [direct\_internet\_access](#input\_direct\_internet\_access) | Set to Disabled to disable internet access to notebook. Requires security\_groups and subnet\_id to be set. Supported values: Enabled (Default) or Disabled. If set to Disabled, the notebook instance will be able to access resources only in your VPC, and will not be able to connect to Amazon SageMaker training and endpoint services unless your configure a NAT Gateway in your VPC. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The name of ML compute instance type. | `string` | n/a | yes |
| <a name="input_lifecycle_config_name"></a> [lifecycle\_config\_name](#input\_lifecycle\_config\_name) | The name of a lifecycle configuration to associate with the notebook instance. | `string` | n/a | yes |
| <a name="input_metadata_service_version"></a> [metadata\_service\_version](#input\_metadata\_service\_version) | Indicates the minimum IMDS version that the notebook instance supports. When passed 1 is passed. This means that both IMDSv1 and IMDSv2 are supported. Valid values are 1 and 2. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the notebook instance (must be unique). | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_platform_identifier"></a> [platform\_identifier](#input\_platform\_identifier) | The platform identifier of the notebook instance runtime environment. This value can be either notebook-al1-v1, notebook-al2-v1, or notebook-al2-v2, depending on which version of Amazon Linux you require. | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | AWS service of the iam role | `list(string)` | n/a | yes |
| <a name="input_root_access"></a> [root\_access](#input\_root\_access) | Whether root access is Enabled or Disabled for users of the notebook instance. The default value is Enabled. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size, in GB, of the ML storage volume to attach to the notebook instance. The default value is 5 GB. | `number` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notebook_arn"></a> [notebook\_arn](#output\_notebook\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this notebook instance. |
| <a name="output_notebook_id"></a> [notebook\_id](#output\_notebook\_id) | The name of the notebook instance. |
| <a name="output_notebook_interface_id"></a> [notebook\_interface\_id](#output\_notebook\_interface\_id) | The network interface ID that Amazon SageMaker created at the time of creating the instance. Only available when setting subnet\_id. |
| <a name="output_notebook_url"></a> [notebook\_url](#output\_notebook\_url) | The URL that you use to connect to the Jupyter notebook that is running in your notebook instance. |

<!-- END_TF_DOCS -->