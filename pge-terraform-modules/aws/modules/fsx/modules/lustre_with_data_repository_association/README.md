<!-- BEGIN_TF_DOCS -->
# AWS Fsx lustre with data repository association
Terraform module which creates SAF2.0 fsx lustre with data repository association in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
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
| [aws_fsx_data_repository_association.data_repository_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_data_repository_association) | resource |
| [aws_fsx_lustre_file_system.lustre](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_lustre_file_system) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_export_policy_events"></a> [auto\_export\_policy\_events](#input\_auto\_export\_policy\_events) | A list of file event types to automatically export to your linked S3 bucket. Valid values are NEW, CHANGED, DELETED. | `list(string)` | `null` | no |
| <a name="input_auto_import_policy_events"></a> [auto\_import\_policy\_events](#input\_auto\_import\_policy\_events) | A list of file event types automatically import from the linked S3 bucket. Valid values are NEW, CHANGED, DELETED. Max of 3. | `list(string)` | `null` | no |
| <a name="input_backup_id"></a> [backup\_id](#input\_backup\_id) | The ID of the source backup to create the filesystem from. | `string` | `null` | no |
| <a name="input_batch_import_meta_data_on_create"></a> [batch\_import\_meta\_data\_on\_create](#input\_batch\_import\_meta\_data\_on\_create) | Set to true to run an import data repository task to import metadata from the data repository to the file system after the data repository association is created. | `bool` | `false` | no |
| <a name="input_copy_tags_to_backups"></a> [copy\_tags\_to\_backups](#input\_copy\_tags\_to\_backups) | A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false. | `bool` | `false` | no |
| <a name="input_data_compression_type"></a> [data\_compression\_type](#input\_data\_compression\_type) | Sets the data compression configuration for the file system. Valid values are LZ4 and NONE. Default value is NONE. | `string` | `"NONE"` | no |
| <a name="input_data_repository_association_timeouts"></a> [data\_repository\_association\_timeouts](#input\_data\_repository\_association\_timeouts) | Provide the timeouts configurations for data\_repository\_association. | `map(string)` | `{}` | no |
| <a name="input_data_repository_path"></a> [data\_repository\_path](#input\_data\_repository\_path) | The path to the Amazon S3 data repository that will be linked to the file system. | `string` | n/a | yes |
| <a name="input_delete_data_in_filesystem"></a> [delete\_data\_in\_filesystem](#input\_delete\_data\_in\_filesystem) | Set to true to delete files from the file system upon deleting this data repository association. | `bool` | `false` | no |
| <a name="input_file_system_path"></a> [file\_system\_path](#input\_file\_system\_path) | A path on the file system that points to a high-level directory (such as /ns1/) or subdirectory (such as /ns1/subdir/) that will be mapped 1-1 with data\_repository\_path. | `string` | n/a | yes |
| <a name="input_file_system_type_version"></a> [file\_system\_type\_version](#input\_file\_system\_type\_version) | Sets the Lustre version for the file system that you're creating.Valid values for 2.12 include all deployment types. | `string` | `"2.12"` | no |
| <a name="input_imported_file_chunk_size"></a> [imported\_file\_chunk\_size](#input\_imported\_file\_chunk\_size) | For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN for the KMS Key to encrypt the file system at rest. | `string` | n/a | yes |
| <a name="input_lustre_log_configuration_destination"></a> [lustre\_log\_configuration\_destination](#input\_lustre\_log\_configuration\_destination) | The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix. If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group. | `string` | `null` | no |
| <a name="input_lustre_log_configuration_level"></a> [lustre\_log\_configuration\_level](#input\_lustre\_log\_configuration\_level) | Sets which data repository events are logged by Amazon FSx. Valid values are WARN\_ONLY, FAILURE\_ONLY, ERROR\_ONLY, WARN\_ERROR and DISABLED. | `string` | `"DISABLED"` | no |
| <a name="input_lustre_timeouts"></a> [lustre\_timeouts](#input\_lustre\_timeouts) | Provide the timeouts configurations for lustre file system. | `map(string)` | `{}` | no |
| <a name="input_per_unit_storage_throughput"></a> [per\_unit\_storage\_throughput](#input\_per\_unit\_storage\_throughput) | Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB. Valid values for PERSISTENT\_2 deployment\_type and SSD storage\_type are 125, 250, 500, 1000. | `number` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces. | `list(string)` | n/a | yes |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | The storage capacity (GiB) of the file system. Minimum of 1200. | `number` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of IDs for the subnets that the file system will be accessible from. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_weekly_maintenance_start_time"></a> [weekly\_maintenance\_start\_time](#input\_weekly\_maintenance\_start\_time) | The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_repository_association_arn"></a> [data\_repository\_association\_arn](#output\_data\_repository\_association\_arn) | Amazon Resource Name of the file system. |
| <a name="output_data_repository_association_id"></a> [data\_repository\_association\_id](#output\_data\_repository\_association\_id) | Identifier of the data repository association. |
| <a name="output_data_repository_association_tags_all"></a> [data\_repository\_association\_tags\_all](#output\_data\_repository\_association\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_fsx_lustre_file_system_arn"></a> [fsx\_lustre\_file\_system\_arn](#output\_fsx\_lustre\_file\_system\_arn) | Amazon Resource Name of the file system. |
| <a name="output_fsx_lustre_file_system_dns_name"></a> [fsx\_lustre\_file\_system\_dns\_name](#output\_fsx\_lustre\_file\_system\_dns\_name) | DNS name for the file system. |
| <a name="output_fsx_lustre_file_system_id"></a> [fsx\_lustre\_file\_system\_id](#output\_fsx\_lustre\_file\_system\_id) | Identifier of the file system. |
| <a name="output_fsx_lustre_file_system_mount_name"></a> [fsx\_lustre\_file\_system\_mount\_name](#output\_fsx\_lustre\_file\_system\_mount\_name) | Identifier of the file system. |
| <a name="output_fsx_lustre_file_system_network_interface_ids"></a> [fsx\_lustre\_file\_system\_network\_interface\_ids](#output\_fsx\_lustre\_file\_system\_network\_interface\_ids) | Set of Elastic Network Interface identifiers from which the file system is accessible. |
| <a name="output_fsx_lustre_file_system_owner_id"></a> [fsx\_lustre\_file\_system\_owner\_id](#output\_fsx\_lustre\_file\_system\_owner\_id) | AWS account identifier that created the file system. |
| <a name="output_fsx_lustre_file_system_tags_all"></a> [fsx\_lustre\_file\_system\_tags\_all](#output\_fsx\_lustre\_file\_system\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_fsx_lustre_file_system_vpc_id"></a> [fsx\_lustre\_file\_system\_vpc\_id](#output\_fsx\_lustre\_file\_system\_vpc\_id) | Identifier of the Virtual Private Cloud for the file system. |


<!-- END_TF_DOCS -->