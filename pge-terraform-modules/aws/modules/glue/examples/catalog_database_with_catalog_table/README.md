<!-- BEGIN_TF_DOCS -->
# AWS Glue Catalog Database, Catalog Table, Glue Partition, Glue Partition Index and User Defined Function creation example
Terraform module which creates SAF2.0 Glue registry resources in AWS.
While creating catalog table using s3 as the storage\_descriptor location, then grant data location permissions from the AWS Lake Formation to s3.

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
| <a name="module_catalog_database"></a> [catalog\_database](#module\_catalog\_database) | ../../modules/catalog_database | n/a |
| <a name="module_catalog_table"></a> [catalog\_table](#module\_catalog\_table) | ../../modules/catalog_table | n/a |
| <a name="module_glue_partition_index"></a> [glue\_partition\_index](#module\_glue\_partition\_index) | ../../modules/glue_partition_index | n/a |
| <a name="module_partition"></a> [partition](#module\_partition) | ../../modules/partition | n/a |
| <a name="module_user_defined_function"></a> [user\_defined\_function](#module\_user\_defined\_function) | ../../modules/user_defined_function | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_class_name"></a> [class\_name](#input\_class\_name) | The Java class that contains the function code. | `string` | n/a | yes |
| <a name="input_columns_name_1"></a> [columns\_name\_1](#input\_columns\_name\_1) | The name of the Column. | `string` | n/a | yes |
| <a name="input_columns_name_2"></a> [columns\_name\_2](#input\_columns\_name\_2) | The name of the Column. | `string` | n/a | yes |
| <a name="input_columns_name_3"></a> [columns\_name\_3](#input\_columns\_name\_3) | The name of the Column. | `string` | n/a | yes |
| <a name="input_columns_name_4"></a> [columns\_name\_4](#input\_columns\_name\_4) | The name of the Column. | `string` | n/a | yes |
| <a name="input_columns_type_1"></a> [columns\_type\_1](#input\_columns\_type\_1) | The datatype of data in the Column. | `string` | n/a | yes |
| <a name="input_columns_type_2"></a> [columns\_type\_2](#input\_columns\_type\_2) | The datatype of data in the Column. | `string` | n/a | yes |
| <a name="input_columns_type_3"></a> [columns\_type\_3](#input\_columns\_type\_3) | The datatype of data in the Column. | `string` | n/a | yes |
| <a name="input_columns_type_4"></a> [columns\_type\_4](#input\_columns\_type\_4) | The datatype of data in the Column. | `string` | n/a | yes |
| <a name="input_compressed"></a> [compressed](#input\_compressed) | True if the data in the table is compressed, or False if not. | `string` | n/a | yes |
| <a name="input_create_table_default_permission"></a> [create\_table\_default\_permission](#input\_create\_table\_default\_permission) | Creates a set of default permissions on the table for principals. | `any` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the database | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | The name of the function. | `string` | n/a | yes |
| <a name="input_glue_partition_values"></a> [glue\_partition\_values](#input\_glue\_partition\_values) | The values that define the partition. | `list(string)` | n/a | yes |
| <a name="input_input_format"></a> [input\_format](#input\_input\_format) | The input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The physical location of the table. By default this takes the form of the warehouse location. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the database. The acceptable characters are lowercase letters, numbers, and the underscore character | `string` | n/a | yes |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | The output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format. | `string` | n/a | yes |
| <a name="input_owner_name"></a> [owner\_name](#input\_owner\_name) | The owner of the function. | `string` | n/a | yes |
| <a name="input_owner_type"></a> [owner\_type](#input\_owner\_type) | The owner type. can be one of USER, ROLE, and GROUP. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Properties associated with this table, as a list of key-value pairs | `map(string)` | n/a | yes |
| <a name="input_partition_index_keys"></a> [partition\_index\_keys](#input\_partition\_index\_keys) | Keys for the partition index | `list(string)` | n/a | yes |
| <a name="input_partition_index_name"></a> [partition\_index\_name](#input\_partition\_index\_name) | Name of the partition index | `string` | n/a | yes |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys | `list(map(string))` | n/a | yes |
| <a name="input_partition_parameters"></a> [partition\_parameters](#input\_partition\_parameters) | User-supplied properties in key-value form. | `map(string)` | n/a | yes |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | The type of the resource. | `string` | n/a | yes |
| <a name="input_ser_de_info_name"></a> [ser\_de\_info\_name](#input\_ser\_de\_info\_name) | Name of the SerDe. | `string` | n/a | yes |
| <a name="input_ser_de_info_parameters"></a> [ser\_de\_info\_parameters](#input\_ser\_de\_info\_parameters) | A map of initialization parameters for the SerDe, in key-value form. | `map(string)` | n/a | yes |
| <a name="input_ser_de_info_serializationLib"></a> [ser\_de\_info\_serializationLib](#input\_ser\_de\_info\_serializationLib) | Usually the class that implements the SerDe. | `string` | n/a | yes |
| <a name="input_storage_descriptor"></a> [storage\_descriptor](#input\_storage\_descriptor) | Configuration block for information about the physical storage of this table | `list(any)` | n/a | yes |
| <a name="input_stored_as_sub_directories"></a> [stored\_as\_sub\_directories](#input\_stored\_as\_sub\_directories) | True if the table data is stored in subdirectories, or False if not. | `string` | n/a | yes |
| <a name="input_table_type"></a> [table\_type](#input\_table\_type) | Type of this table (EXTERNAL\_TABLE, VIRTUAL\_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty | `string` | n/a | yes |
| <a name="input_uri"></a> [uri](#input\_uri) | The URI for accessing the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog_database_arn"></a> [catalog\_database\_arn](#output\_catalog\_database\_arn) | ARN of the Glue Catalog Database |
| <a name="output_catalog_database_id"></a> [catalog\_database\_id](#output\_catalog\_database\_id) | Catalog ID and name of the database |
| <a name="output_catalog_table_arn"></a> [catalog\_table\_arn](#output\_catalog\_table\_arn) | The ARN of the Glue Table |
| <a name="output_catalog_table_id"></a> [catalog\_table\_id](#output\_catalog\_table\_id) | Catalog ID, Database name and of the name table |
| <a name="output_glue_partion_last_accessed_time"></a> [glue\_partion\_last\_accessed\_time](#output\_glue\_partion\_last\_accessed\_time) | The last time at which the partition was accessed. |
| <a name="output_glue_partition_creation_time"></a> [glue\_partition\_creation\_time](#output\_glue\_partition\_creation\_time) | The time at which the partition was created. |
| <a name="output_glue_partition_id"></a> [glue\_partition\_id](#output\_glue\_partition\_id) | partition id. |
| <a name="output_glue_partition_last_analyzed_time"></a> [glue\_partition\_last\_analyzed\_time](#output\_glue\_partition\_last\_analyzed\_time) | The last time at which column statistics were computed for this partition. |
| <a name="output_partition_index_id"></a> [partition\_index\_id](#output\_partition\_index\_id) | Catalog ID, Database name,table name, and index name. |


<!-- END_TF_DOCS -->