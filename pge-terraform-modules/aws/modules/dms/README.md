<!-- BEGIN_TF_DOCS -->
# AWS DMS Replication Task module.
Terraform module which creates SAF2.0 DMS Replication Task in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.35.1 |

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
| [aws_dms_replication_task.dms_replication_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cdc_start_position"></a> [cdc\_start\_position](#input\_cdc\_start\_position) | Indicates when you want a change data capture (CDC) operation to start. The value can be in date, checkpoint, or LSN/SCN format depending on the source engine. For more information, see Determining a CDC native start point.Conflicts with cdc\_start\_time. | `string` | `null` | no |
| <a name="input_cdc_start_time"></a> [cdc\_start\_time](#input\_cdc\_start\_time) | The Unix timestamp integer for the start of the Change Data Capture (CDC) operation.Conflicts with cdc\_start\_position. | `string` | `null` | no |
| <a name="input_migration_type"></a> [migration\_type](#input\_migration\_type) | The migration type. Can be one of full-load \| cdc \| full-load-and-cdc. | `string` | n/a | yes |
| <a name="input_replication_instance_arn"></a> [replication\_instance\_arn](#input\_replication\_instance\_arn) | The Amazon Resource Name (ARN) of the replication instance. | `string` | n/a | yes |
| <a name="input_replication_task_id"></a> [replication\_task\_id](#input\_replication\_task\_id) | The replication task identifier.Must contain from 1 to 255 alphanumeric characters or hyphens.First character must be a letter.Cannot end with a hyphen.Cannot contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_replication_task_settings"></a> [replication\_task\_settings](#input\_replication\_task\_settings) | An escaped JSON string that contains the task settings. For a complete list of task settings, see Task Settings for AWS Database Migration Service Tasks. | `string` | `null` | no |
| <a name="input_source_endpoint_arn"></a> [source\_endpoint\_arn](#input\_source\_endpoint\_arn) | The Amazon Resource Name (ARN) string that uniquely identifies the source endpoint. | `string` | n/a | yes |
| <a name="input_start_replication_task"></a> [start\_replication\_task](#input\_start\_replication\_task) | Whether to run or stop the replication task. | `string` | `null` | no |
| <a name="input_table_mappings"></a> [table\_mappings](#input\_table\_mappings) | An escaped JSON string that contains the table mappings. For information on table mapping see Using Table Mapping with an AWS Database Migration Service Task to Select and Filter Data. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_target_endpoint_arn"></a> [target\_endpoint\_arn](#input\_target\_endpoint\_arn) | The Amazon Resource Name (ARN) string that uniquely identifies the target endpoint. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_replication_task_all"></a> [dms\_replication\_task\_all](#output\_dms\_replication\_task\_all) | A map of aws dms replication task |
| <a name="output_replication_task_arn"></a> [replication\_task\_arn](#output\_replication\_task\_arn) | The Amazon Resource Name (ARN) for the replication task. |
| <a name="output_replication_task_status"></a> [replication\_task\_status](#output\_replication\_task\_status) | Status of the replication task. |
| <a name="output_replication_task_tags_all"></a> [replication\_task\_tags\_all](#output\_replication\_task\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->