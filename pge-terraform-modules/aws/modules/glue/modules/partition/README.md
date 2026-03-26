<!-- BEGIN_TF_DOCS -->
# AWS Glue partition module.
Terraform module which creates SAF2.0 Glue partition in AWS.

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

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_glue_partition.glue_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_partition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_partition_catalog_id"></a> [glue\_partition\_catalog\_id](#input\_glue\_partition\_catalog\_id) | ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name. | `string` | `null` | no |
| <a name="input_glue_partition_database_name"></a> [glue\_partition\_database\_name](#input\_glue\_partition\_database\_name) | Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase. | `string` | n/a | yes |
| <a name="input_glue_partition_parameters"></a> [glue\_partition\_parameters](#input\_glue\_partition\_parameters) | Properties associated with this table, as a list of key-value pairs. | `map(string)` | `null` | no |
| <a name="input_glue_partition_storage_descriptor"></a> [glue\_partition\_storage\_descriptor](#input\_glue\_partition\_storage\_descriptor) | A storage descriptor object containing information about the physical storage of this table. | `any` | `null` | no |
| <a name="input_glue_partition_table_name"></a> [glue\_partition\_table\_name](#input\_glue\_partition\_table\_name) | Name of the table metadata resides. | `string` | n/a | yes |
| <a name="input_glue_partition_values"></a> [glue\_partition\_values](#input\_glue\_partition\_values) | The values that define the partition. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_partition"></a> [aws\_glue\_partition](#output\_aws\_glue\_partition) | A map of aws\_glue\_partition object. |
| <a name="output_glue_partion_last_accessed_time"></a> [glue\_partion\_last\_accessed\_time](#output\_glue\_partion\_last\_accessed\_time) | The last time at which the partition was accessed. |
| <a name="output_glue_partition_creation_time"></a> [glue\_partition\_creation\_time](#output\_glue\_partition\_creation\_time) | The time at which the partition was created. |
| <a name="output_glue_partition_id"></a> [glue\_partition\_id](#output\_glue\_partition\_id) | partition id. |
| <a name="output_glue_partition_last_analyzed_time"></a> [glue\_partition\_last\_analyzed\_time](#output\_glue\_partition\_last\_analyzed\_time) | The last time at which column statistics were computed for this partition. |


<!-- END_TF_DOCS -->