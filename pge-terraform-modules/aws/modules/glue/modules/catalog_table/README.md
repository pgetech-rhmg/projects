<!-- BEGIN_TF_DOCS -->
# AWS Glue Catalog\_table module.
Terraform module which creates SAF2.0 Glue Catalog\_table in AWS.

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
| [aws_glue_catalog_table.glue_catalog_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the table | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the table. For Hive compatibility, this must be entirely lowercase | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the table | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Properties associated with this table, as a list of key-value pairs | `map(string)` | `null` | no |
| <a name="input_partition_index"></a> [partition\_index](#input\_partition\_index) | Configuration block for a maximum of 3 partition indexes | `list(map(string))` | `[]` | no |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys | `list(map(string))` | `[]` | no |
| <a name="input_retention"></a> [retention](#input\_retention) | Retention time for this table | `string` | `null` | no |
| <a name="input_storage_descriptor"></a> [storage\_descriptor](#input\_storage\_descriptor) | Configuration block for information about the physical storage of this table | `list(any)` | `[]` | no |
| <a name="input_table_type"></a> [table\_type](#input\_table\_type) | Type of this table (EXTERNAL\_TABLE, VIRTUAL\_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty | `string` | `null` | no |
| <a name="input_target_table"></a> [target\_table](#input\_target\_table) | Configuration block of a target table for resource linking | `list(map(string))` | `[]` | no |
| <a name="input_view_expanded_text"></a> [view\_expanded\_text](#input\_view\_expanded\_text) | If the table is a view, the expanded text of the view; otherwise null | `string` | `null` | no |
| <a name="input_view_original_text"></a> [view\_original\_text](#input\_view\_original\_text) | If the table is a view, the original text of the view; otherwise null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Glue Table |
| <a name="output_aws_glue_catalog_table"></a> [aws\_glue\_catalog\_table](#output\_aws\_glue\_catalog\_table) | Map of aws\_glue\_catalog\_table object |
| <a name="output_id"></a> [id](#output\_id) | Catalog ID, Database name and of the name table |
| <a name="output_name"></a> [name](#output\_name) | Catalog ID, Database name and of the name table |


<!-- END_TF_DOCS -->