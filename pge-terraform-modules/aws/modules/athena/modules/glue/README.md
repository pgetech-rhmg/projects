<!-- BEGIN_TF_DOCS -->
Athena Glue Submodule

Description:
  Provisions AWS Glue Data Catalog resources to support
  Athena queries. This submodule creates a Glue database
  and an external table with a defined schema pointing
  to data stored in Amazon S3.

  This module is optional and intended to be composed
  alongside the base Athena workgroup module.

Resources Created:
  - aws\_glue\_catalog\_database
  - aws\_glue\_catalog\_table

Module Path:
  aws/modules/athena/modules/glue

Author:
  PG&E Cloud Engineering

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.3 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_columns"></a> [columns](#input\_columns) | List of column definitions for the Glue table schema, including column name and data type. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_data_bucket"></a> [data\_bucket](#input\_data\_bucket) | S3 bucket containing the data files used by the Glue external table. | `string` | n/a | yes |
| <a name="input_data_prefix"></a> [data\_prefix](#input\_data\_prefix) | S3 prefix (folder path) where the Glue table's data is stored. | `string` | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | Name of the Glue database to create or reference for Athena queries. | `string` | n/a | yes |
| <a name="input_glue_table_name"></a> [glue\_table\_name](#input\_glue\_table\_name) | Name of the Glue table to create or reference within the specified database. | `string` | n/a | yes |
| <a name="input_input_format"></a> [input\_format](#input\_input\_format) | Input format class used by the Glue table to read data from S3. | `string` | `"org.apache.hadoop.mapred.TextInputFormat"` | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | Output format class used by the Glue table when writing data. | `string` | `"org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"` | no |
| <a name="input_serde_parameters"></a> [serde\_parameters](#input\_serde\_parameters) | Key-value parameters passed to the SerDe library, such as field delimiters. | `map(string)` | <pre>{<br/>  "field.delim": ","<br/>}</pre> | no |
| <a name="input_serialization_library"></a> [serialization\_library](#input\_serialization\_library) | SerDe library used to serialize and deserialize table data. | `string` | `"org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the AWS Glue database created or referenced by this module. |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name of the AWS Glue table created or referenced within the database. |

<!-- END_TF_DOCS -->