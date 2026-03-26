<!-- BEGIN_TF_DOCS -->
# AWS Fsx windows and lustre file system
Terraform module which creates SAF2.0 fsx windows and lustre file system in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| [aws_fsx_lustre_file_system.lustre](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_lustre_file_system) | resource |
| [aws_fsx_windows_file_system.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automatic_backup_retention_days"></a> [automatic\_backup\_retention\_days](#input\_automatic\_backup\_retention\_days) | The number of days to retain automatic backups. Minimum of 0 and maximum of 35. Defaults to 7. Set to 0 to disable. | `number` | `15` | no |
| <a name="input_backup_id"></a> [backup\_id](#input\_backup\_id) | The ID of the source backup to create the filesystem from. | `string` | `null` | no |
| <a name="input_copy_tags_to_backups"></a> [copy\_tags\_to\_backups](#input\_copy\_tags\_to\_backups) | A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false. | `bool` | `false` | no |
| <a name="input_daily_automatic_backup_start_time"></a> [daily\_automatic\_backup\_start\_time](#input\_daily\_automatic\_backup\_start\_time) | The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone. | `string` | `null` | no |
| <a name="input_file_system"></a> [file\_system](#input\_file\_system) | file\_system\_type:<br>   The type of file system.Valid values are windows & lustre.<br>storage\_capacity:<br>  Storage capacity (GiB) of the file system.<br>deployment\_type:<br>  Specifies the file system deployment type.<br>windows\_throughput\_capacity:<br>  Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048.<br>windows\_preferred\_subnet\_id:<br>  Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI\_AZ\_1.<br>windows\_shared\_active\_directory\_id:<br>  The ID for an existing Microsoft Active Directory instance that the file system should join when it's created. <br>storage\_type:<br>   Specifies the storage type, Valid values are SSD and HDD<br>lustre\_per\_unit\_storage\_throughput:<br>   Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB, required for the PERSISTENT\_1 and PERSISTENT\_2 deployment\_type. Valid values for PERSISTENT\_1 deployment\_type and SSD storage\_type are 50, 100, 200. Valid values for PERSISTENT\_1 deployment\_type and HDD storage\_type are 12, 40. Valid values for PERSISTENT\_2 deployment\_type and SSD storage\_type are 125, 250, 500, 1000.<br>lustre\_drive\_cache\_type:<br>   The type of drive cache used by PERSISTENT\_1 filesystems that are provisioned with HDD storage\_type. Required for HDD storage\_type, set to either READ or NONE.         <br>windows\_aliases<br>   An array DNS alias names that you want to associate with the Amazon FSx file system.<br>windows\_skip\_final\_backup<br>   When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false.<br>lustre\_auto\_import\_policy<br>   How Amazon FSx keeps your file and directory listings up to date as you add or modify objects in your linked S3 bucket.<br>lustre\_data\_compression\_type<br>   Sets the data compression configuration for the file system. Valid values are LZ4 and NONE. Default value is NONE.<br>lustre\_file\_system\_type\_version<br>   Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH\_1, SCRATCH\_2 and PERSISTENT\_1 deployment types. Valid values for 2.12 include all deployment types.<br>lustre\_export\_path<br>   S3 URI (with optional prefix) where the root of your Amazon FSx file system is exported.<br>lustre\_import\_path <br>   S3 URI (with optional prefix) that you're using as the data repository for your FSx for Lustre file system.<br>lustre\_imported\_file\_chunk\_size <br>   For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk. Can only be specified with import\_path argument. Defaults to 1024.<br>lustre\_log\_configuration\_destination<br>   The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix. If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group.<br>lustre\_log\_configuration\_level<br>   Sets which data repository events are logged by Amazon FSx. Valid values are WARN\_ONLY, FAILURE\_ONLY, ERROR\_ONLY, WARN\_ERROR and DISABLED.<br>windows\_audit\_log\_destination<br>  The Amazon Resource Name (ARN) for the destination of the audit logs. The destination can be any Amazon CloudWatch Logs log group ARN or Amazon Kinesis Data Firehose delivery stream ARN.<br>windows\_file\_access\_audit\_log\_level<br>  Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. Default value is DISABLED.<br>windows\_file\_share\_access\_audit\_log\_level<br>  Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. Default value is DISABLED. | <pre>object({<br>    file_system_type                          = string<br>    storage_capacity                          = number<br>    deployment_type                           = string<br>    windows_throughput_capacity               = number<br>    windows_preferred_subnet_id               = string<br>    windows_shared_active_directory_id        = string<br>    storage_type                              = string<br>    lustre_per_unit_storage_throughput        = number<br>    lustre_drive_cache_type                   = string<br>    windows_aliases                           = list(string)<br>    windows_skip_final_backup                 = bool<br>    lustre_auto_import_policy                 = string<br>    lustre_data_compression_type              = string<br>    lustre_file_system_type_version           = string<br>    lustre_export_path                        = string<br>    lustre_import_path                        = string<br>    lustre_imported_file_chunk_size           = number<br>    lustre_log_configuration_destination      = string<br>    lustre_log_configuration_level            = string<br>    windows_audit_log_destination             = string<br>    windows_file_access_audit_log_level       = string<br>    windows_file_share_access_audit_log_level = string<br>  })</pre> | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS Key to encrypt the file system at rest. Defaults to an AWS managed KMS Key. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment\_type to MULTI\_AZ\_1. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | provides the following Timeouts configuration options: create, update, delete. | `map(string)` | `{}` | no |
| <a name="input_weekly_maintenance_start_time"></a> [weekly\_maintenance\_start\_time](#input\_weekly\_maintenance\_start\_time) | The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_lustre_file_system_arn"></a> [fsx\_lustre\_file\_system\_arn](#output\_fsx\_lustre\_file\_system\_arn) | Amazon Resource Name of the file system. |
| <a name="output_fsx_lustre_file_system_dns_name"></a> [fsx\_lustre\_file\_system\_dns\_name](#output\_fsx\_lustre\_file\_system\_dns\_name) | DNS name for the file system. |
| <a name="output_fsx_lustre_file_system_id"></a> [fsx\_lustre\_file\_system\_id](#output\_fsx\_lustre\_file\_system\_id) | Identifier of the file system. |
| <a name="output_fsx_lustre_file_system_mount_name"></a> [fsx\_lustre\_file\_system\_mount\_name](#output\_fsx\_lustre\_file\_system\_mount\_name) | Identifier of the file system. |
| <a name="output_fsx_lustre_file_system_network_interface_ids"></a> [fsx\_lustre\_file\_system\_network\_interface\_ids](#output\_fsx\_lustre\_file\_system\_network\_interface\_ids) | Set of Elastic Network Interface identifiers from which the file system is accessible. |
| <a name="output_fsx_lustre_file_system_owner_id"></a> [fsx\_lustre\_file\_system\_owner\_id](#output\_fsx\_lustre\_file\_system\_owner\_id) | AWS account identifier that created the file system. |
| <a name="output_fsx_lustre_file_system_tags_all"></a> [fsx\_lustre\_file\_system\_tags\_all](#output\_fsx\_lustre\_file\_system\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_fsx_lustre_file_system_vpc_id"></a> [fsx\_lustre\_file\_system\_vpc\_id](#output\_fsx\_lustre\_file\_system\_vpc\_id) | Identifier of the Virtual Private Cloud for the file system. |
| <a name="output_fsx_windows_file_system_arn"></a> [fsx\_windows\_file\_system\_arn](#output\_fsx\_windows\_file\_system\_arn) | Amazon Resource Name of the file system. |
| <a name="output_fsx_windows_file_system_dns_name"></a> [fsx\_windows\_file\_system\_dns\_name](#output\_fsx\_windows\_file\_system\_dns\_name) | DNS name for the file system. |
| <a name="output_fsx_windows_file_system_id"></a> [fsx\_windows\_file\_system\_id](#output\_fsx\_windows\_file\_system\_id) | Identifier of the file system. |
| <a name="output_fsx_windows_file_system_network_interface_ids"></a> [fsx\_windows\_file\_system\_network\_interface\_ids](#output\_fsx\_windows\_file\_system\_network\_interface\_ids) | Set of Elastic Network Interface identifiers from which the file system is accessible. |
| <a name="output_fsx_windows_file_system_owner_id"></a> [fsx\_windows\_file\_system\_owner\_id](#output\_fsx\_windows\_file\_system\_owner\_id) | AWS account identifier that created the file system. |
| <a name="output_fsx_windows_file_system_preferred_file_server_ip"></a> [fsx\_windows\_file\_system\_preferred\_file\_server\_ip](#output\_fsx\_windows\_file\_system\_preferred\_file\_server\_ip) | The IP address of the primary, or preferred, file server. |
| <a name="output_fsx_windows_file_system_remote_administration_endpoint"></a> [fsx\_windows\_file\_system\_remote\_administration\_endpoint](#output\_fsx\_windows\_file\_system\_remote\_administration\_endpoint) | For MULTI\_AZ\_1 deployment types, use this endpoint when performing administrative tasks on the file system using Amazon FSx Remote PowerShell. For SINGLE\_AZ\_1 deployment types, this is the DNS name of the file system. |
| <a name="output_fsx_windows_file_system_tags_all"></a> [fsx\_windows\_file\_system\_tags\_all](#output\_fsx\_windows\_file\_system\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_fsx_windows_file_system_vpc_id"></a> [fsx\_windows\_file\_system\_vpc\_id](#output\_fsx\_windows\_file\_system\_vpc\_id) | Identifier of the Virtual Private Cloud for the file system. |


<!-- END_TF_DOCS -->