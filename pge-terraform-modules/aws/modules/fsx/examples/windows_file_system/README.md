<!-- BEGIN_TF_DOCS -->
# AWS Fsx windows file system module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |
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
| <a name="module_security_group_windows"></a> [security\_group\_windows](#module\_security\_group\_windows) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_windows_backup"></a> [windows\_backup](#module\_windows\_backup) | ../../modules/backup | n/a |
| <a name="module_windows_file_system"></a> [windows\_file\_system](#module\_windows\_file\_system) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.windows_ad_golden](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance    Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Specifies the file system deployment type. | `string` | n/a | yes |
| <a name="input_file_access_audit_log_level"></a> [file\_access\_audit\_log\_level](#input\_file\_access\_audit\_log\_level) | Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. | `string` | n/a | yes |
| <a name="input_file_share_access_audit_log_level"></a> [file\_share\_access\_audit\_log\_level](#input\_file\_share\_access\_audit\_log\_level) | Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. | `string` | n/a | yes |
| <a name="input_file_system_timeouts"></a> [file\_system\_timeouts](#input\_file\_system\_timeouts) | windows\_file\_system provides the following Timeouts configuration options: create, update, delete. | `map(string)` | n/a | yes |
| <a name="input_file_system_type"></a> [file\_system\_type](#input\_file\_system\_type) | The type of file system.Valid values are windows & lustre. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The common name for all the name arguments in resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_skip_final_backup"></a> [skip\_final\_backup](#input\_skip\_final\_backup) | When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false. | `bool` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | Storage capacity (GiB) of the file system. | `number` | n/a | yes |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Specifies the storage type, Valid values are SSD and HDD. | `string` | n/a | yes |
| <a name="input_throughput_capacity"></a> [throughput\_capacity](#input\_throughput\_capacity) | Throughput (megabytes per second) of the file system in power of 2 increments. | `number` | n/a | yes |
| <a name="input_windows_shared_active_directory_id"></a> [windows\_shared\_active\_directory\_id](#input\_windows\_shared\_active\_directory\_id) | The ID for an existing Microsoft Active Directory instance that the file system should join when it's created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_backup_arn"></a> [fsx\_backup\_arn](#output\_fsx\_backup\_arn) | Amazon Resource Name of the backup. |
| <a name="output_fsx_backup_id"></a> [fsx\_backup\_id](#output\_fsx\_backup\_id) | Identifier of the backup |
| <a name="output_fsx_windows_file_system_arn"></a> [fsx\_windows\_file\_system\_arn](#output\_fsx\_windows\_file\_system\_arn) | Amazon Resource Name of the file system. |
| <a name="output_fsx_windows_file_system_id"></a> [fsx\_windows\_file\_system\_id](#output\_fsx\_windows\_file\_system\_id) | Identifier of the file system. |


<!-- END_TF_DOCS -->