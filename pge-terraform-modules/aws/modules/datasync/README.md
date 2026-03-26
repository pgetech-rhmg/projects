<!-- BEGIN_TF_DOCS -->
# AWS DataSync module
Terraform module which creates SAF2.0 DataSync resources in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.11.0 |

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
| <a name="module_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#module\_cloudwatch\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_datasync_task.datasync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atime"></a> [atime](#input\_atime) | A file metadata value that shows the time that the file was last accessed. | `string` | `null` | no |
| <a name="input_bytes_per_second"></a> [bytes\_per\_second](#input\_bytes\_per\_second) | A value that limits the bandwidth used by AWS DataSync. | `number` | `null` | no |
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | Amazon Resource Name (ARN) of the CloudWatch Log group that is used to monitor and log events. | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_name_prefix"></a> [cloudwatch\_log\_group\_name\_prefix](#input\_cloudwatch\_log\_group\_name\_prefix) | Name prefix of the Cloudwatch log group | `string` | `null` | no |
| <a name="input_create_task_report"></a> [create\_task\_report](#input\_create\_task\_report) | Whether to create a task report. | `bool` | `false` | no |
| <a name="input_destination_location_arn"></a> [destination\_location\_arn](#input\_destination\_location\_arn) | Amazon Resource Name (ARN) of destination location. | `string` | n/a | yes |
| <a name="input_excludes"></a> [excludes](#input\_excludes) | List of objects to exclude from the DataSync task | `list(object({ filter_type = string, value = string }))` | `[]` | no |
| <a name="input_gid"></a> [gid](#input\_gid) | The group ID of the file's owner. | `string` | `null` | no |
| <a name="input_includes"></a> [includes](#input\_includes) | List of objects to include in the DataSync task | `list(object({ filter_type = string, value = string }))` | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting logs | `string` | `null` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Determines the type of logs that DataSync publishes to a log stream in the Amazon CloudWatch log group that you provide. Valid values: OFF, BASIC, TRANSFER | `string` | `"TRANSFER"` | no |
| <a name="input_mtime"></a> [mtime](#input\_mtime) | A value that indicates the last time that a file was modified before the sync. Valid values: NONE, PRESERVE. | `string` | `null` | no |
| <a name="input_object_tags"></a> [object\_tags](#input\_object\_tags) | Specifies whether object tags are maintained when transferring between object storage systems. If you want your DataSync task to ignore object tags, specify the NONE value. Valid values: PRESERVE, NONE. | `string` | `null` | no |
| <a name="input_overwrite_mode"></a> [overwrite\_mode](#input\_overwrite\_mode) | Determines whether files at the destination should be overwritten or preserved when copying files. Valid values: ALWAYS, NEVER. | `string` | `null` | no |
| <a name="input_posix_permissions"></a> [posix\_permissions](#input\_posix\_permissions) | Determines which users or groups can access a file for a specific purpose such as reading, writing, or execution of the file. Valid values: NONE, PRESERVE. | `string` | `null` | no |
| <a name="input_preserve_deleted_files"></a> [preserve\_deleted\_files](#input\_preserve\_deleted\_files) | Whether files deleted in the source should be removed or preserved in the destination file system. Valid values: PRESERVE, REMOVE. | `string` | `null` | no |
| <a name="input_preserve_devices"></a> [preserve\_devices](#input\_preserve\_devices) | Whether the DataSync Task should preserve the metadata of block and character devices in the source files system, and recreate the files with that device name and metadata on the destination. Valid values: NONE, PRESERVE | `string` | `null` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | An expression that specifies when DataSync should start a scheduled task. See: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html. | `string` | `null` | no |
| <a name="input_security_descriptor_copy_flags"></a> [security\_descriptor\_copy\_flags](#input\_security\_descriptor\_copy\_flags) | Determines which components of the SMB security descriptor are copied from source to destination objects. This value is only used for transfers between SMB and Amazon FSx for Windows File Server locations, or between two Amazon FSx for Windows File Server locations. Valid values: NONE, OWNER\_DACL, OWNER\_DACL\_SACL. | `string` | `null` | no |
| <a name="input_source_location_arn"></a> [source\_location\_arn](#input\_source\_location\_arn) | Amazon Resource Name (ARN) of source location. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign resources for EFS | `map(string)` | n/a | yes |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | Name of the DataSync Task. | `string` | `null` | no |
| <a name="input_task_queueing"></a> [task\_queueing](#input\_task\_queueing) | Determines whether tasks should be queued before executing the tasks. Valid values: ENABLED, DISABLED. | `string` | `null` | no |
| <a name="input_task_report_bucket_access_role_arn"></a> [task\_report\_bucket\_access\_role\_arn](#input\_task\_report\_bucket\_access\_role\_arn) | The ARN of the role that grants AWS DataSync access to the Amazon S3 bucket. | `string` | `null` | no |
| <a name="input_task_report_deleted_override"></a> [task\_report\_deleted\_override](#input\_task\_report\_deleted\_override) | Specifies the level of reporting for the files, objects, and directories that DataSync attempted to delete in your destination location. This only applies if you configure your task to delete data in the destination that isn't in the source. Valid values: ERRORS\_ONLY and SUCCESSES\_AND\_ERRORS. | `string` | `null` | no |
| <a name="input_task_report_output_type"></a> [task\_report\_output\_type](#input\_task\_report\_output\_type) | Specifies the type of task report you'd like. Valid values: SUMMARY\_ONLY and STANDARD. | `string` | `null` | no |
| <a name="input_task_report_overrides"></a> [task\_report\_overrides](#input\_task\_report\_overrides) | A list of objects that specify overrides for the DataSync task report. | `bool` | `false` | no |
| <a name="input_task_report_s3_bucket_arn"></a> [task\_report\_s3\_bucket\_arn](#input\_task\_report\_s3\_bucket\_arn) | The Amazon Resource Name (ARN) of the S3 bucket. | `string` | `null` | no |
| <a name="input_task_report_s3_object_versioning"></a> [task\_report\_s3\_object\_versioning](#input\_task\_report\_s3\_object\_versioning) | Specifies whether your task report includes the new version of each object transferred into an S3 bucket. This only applies if you enable versioning on your bucket. Keep in mind that setting this to INCLUDE can increase the duration of your task execution. Valid values: INCLUDE and NONE. | `string` | `null` | no |
| <a name="input_task_report_skipped_override"></a> [task\_report\_skipped\_override](#input\_task\_report\_skipped\_override) | Specifies the level of reporting for the files, objects, and directories that DataSync attempted to skip during your transfer. Valid values: ERRORS\_ONLY and SUCCESSES\_AND\_ERRORS. | `string` | `null` | no |
| <a name="input_task_report_subdirectory"></a> [task\_report\_subdirectory](#input\_task\_report\_subdirectory) | The subdirectory in the S3 bucket to which to write the DataSync task report. | `string` | `null` | no |
| <a name="input_task_report_transferred_override"></a> [task\_report\_transferred\_override](#input\_task\_report\_transferred\_override) | Specifies the level of reporting for the files, objects, and directories that DataSync attempted to transfer. Valid values: ERRORS\_ONLY and SUCCESSES\_AND\_ERRORS. | `string` | `null` | no |
| <a name="input_task_report_verified_override"></a> [task\_report\_verified\_override](#input\_task\_report\_verified\_override) | Specifies the level of reporting for the files, objects, and directories that DataSync attempted to verify at the end of your transfer. Valid values: ERRORS\_ONLY and SUCCESSES\_AND\_ERRORS. | `string` | `null` | no |
| <a name="input_transfer_mode"></a> [transfer\_mode](#input\_transfer\_mode) | Determines whether DataSync transfers only the data and metadata that differ between the source and the destination location, or whether DataSync transfers all the content from the source, without comparing to the destination location. Valid values: CHANGED, ALL. | `string` | `null` | no |
| <a name="input_uid"></a> [uid](#input\_uid) | User identifier of the file's owners. Valid values: BOTH, INT\_VALUE, NAME, NONE | `string` | `null` | no |
| <a name="input_verify_mode"></a> [verify\_mode](#input\_verify\_mode) | Whether a data integrity verification should be performed at the end of a task execution after all data and metadata have been transferred. Valid values: NONE, POINT\_IN\_TIME\_CONSISTENT, ONLY\_FILES\_TRANSFERRED. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the DataSync Task. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the DataSync Task. |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the DataSync Task. |


<!-- END_TF_DOCS -->