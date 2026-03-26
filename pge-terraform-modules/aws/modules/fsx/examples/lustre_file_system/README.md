<!-- BEGIN_TF_DOCS -->
# AWS Fsx lustre file system module example

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
| <a name="module_lustre_backup"></a> [lustre\_backup](#module\_lustre\_backup) | ../../modules/backup | n/a |
| <a name="module_lustre_file_system"></a> [lustre\_file\_system](#module\_lustre\_file\_system) | ../.. | n/a |
| <a name="module_security_group_lustre"></a> [security\_group\_lustre](#module\_security\_group\_lustre) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.fsx_lustre_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_file_system_type"></a> [file\_system\_type](#input\_file\_system\_type) | The type of file system.Valid values are windows & lustre. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_log_configuration_level"></a> [log\_configuration\_level](#input\_log\_configuration\_level) | Sets which data repository events are logged by Amazon FSx. | `string` | n/a | yes |
| <a name="input_lustre_data_compression_type"></a> [lustre\_data\_compression\_type](#input\_lustre\_data\_compression\_type) | Sets the data compression configuration for the file system. Valid values are LZ4 and NONE. | `string` | n/a | yes |
| <a name="input_lustre_file_system_type_version"></a> [lustre\_file\_system\_type\_version](#input\_lustre\_file\_system\_type\_version) | Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH\_1, SCRATCH\_2 and PERSISTENT\_1 deployment types. Valid values for 2.12 include all deployment types. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The common name for all the name arguments in resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_per_unit_storage_throughput"></a> [per\_unit\_storage\_throughput](#input\_per\_unit\_storage\_throughput) | Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | Storage capacity (GiB) of the file system. | `number` | n/a | yes |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Specifies the storage type, Valid values are SSD and HDD. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_backup_arn"></a> [fsx\_backup\_arn](#output\_fsx\_backup\_arn) | Amazon Resource Name of the backup. |
| <a name="output_fsx_backup_id"></a> [fsx\_backup\_id](#output\_fsx\_backup\_id) | Identifier of the backup |
| <a name="output_fsx_lustre_file_system_arn"></a> [fsx\_lustre\_file\_system\_arn](#output\_fsx\_lustre\_file\_system\_arn) | Amazon Resource Name of the file system. |
| <a name="output_fsx_lustre_file_system_id"></a> [fsx\_lustre\_file\_system\_id](#output\_fsx\_lustre\_file\_system\_id) | Identifier of the file system. |


<!-- END_TF_DOCS -->