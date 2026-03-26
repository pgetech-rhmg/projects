<!-- BEGIN_TF_DOCS -->
# AWS DMS S3 Target Endpoint module.
Terraform module which creates SAF2.0 DMS S3 Target Endpoint in AWS.

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
| [aws_dms_endpoint.dms_source_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_s3_endpoint.dms_s3_target_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_s3_endpoint) | resource |
| [external_external.validate_kms_endpoint_kms_key_arn](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.validate_kms_source_endpoint_kms_key_arn](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_column_name"></a> [add\_column\_name](#input\_add\_column\_name) | Whether to add column name information to the .csv output files. Default is false. | `bool` | `false` | no |
| <a name="input_cdc_inserts_only"></a> [cdc\_inserts\_only](#input\_cdc\_inserts\_only) | Whether to write only INSERT operations to .csv or .parquet output files. Default is false. | `bool` | `false` | no |
| <a name="input_compression_type"></a> [compression\_type](#input\_compression\_type) | Type of compression to apply to the data. Valid values: NONE, GZIP. Default is NONE. | `string` | `"NONE"` | no |
| <a name="input_csv_delimiter"></a> [csv\_delimiter](#input\_csv\_delimiter) | Character used to separate columns in CSV files. Default is comma (,). | `string` | `","` | no |
| <a name="input_csv_row_delimiter"></a> [csv\_row\_delimiter](#input\_csv\_row\_delimiter) | Character used to separate rows in CSV files. Default is newline (\n). | `string` | `"\\n"` | no |
| <a name="input_data_format"></a> [data\_format](#input\_data\_format) | Output data format. Valid values: csv, parquet. Default is csv. | `string` | `"csv"` | no |
| <a name="input_date_partition_enabled"></a> [date\_partition\_enabled](#input\_date\_partition\_enabled) | Whether to partition S3 bucket folders by transaction commit dates. Default is false. | `bool` | `false` | no |
| <a name="input_date_partition_sequence"></a> [date\_partition\_sequence](#input\_date\_partition\_sequence) | Identifies the sequence of the date format to use during folder partitioning. Valid values: YYYYMMDD, YYYYMMDDHH, YYYYMM, MMYYYYDD, DDMMYYYY. Default is YYYYMMDD. | `string` | `"YYYYMMDD"` | no |
| <a name="input_encryption_mode"></a> [encryption\_mode](#input\_encryption\_mode) | Server-side encryption mode. Valid values: SSE\_S3, SSE\_KMS, CSE\_KMS. Default is SSE\_S3. | `string` | `"SSE_S3"` | no |
| <a name="input_endpoint_id"></a> [endpoint\_id](#input\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_external_table_definition"></a> [external\_table\_definition](#input\_external\_table\_definition) | JSON document that describes how AWS DMS should interpret the data. Optional. | `string` | `null` | no |
| <a name="input_ignore_header_rows"></a> [ignore\_header\_rows](#input\_ignore\_header\_rows) | Number of header rows to ignore when loading CSV files. Default is 0. | `number` | `0` | no |
| <a name="input_include_op_for_full_load"></a> [include\_op\_for\_full\_load](#input\_include\_op\_for\_full\_load) | Whether to include operation columns for full load. Default is false. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN for the KMS key that will be used to encrypt the connection parameters. | `string` | `null` | no |
| <a name="input_max_file_size"></a> [max\_file\_size](#input\_max\_file\_size) | Maximum size of encoded, uncompressed .csv file in bytes. Default is 1048576 (1 MB). | `number` | `1048576` | no |
| <a name="input_parquet_timestamp_in_millisecond"></a> [parquet\_timestamp\_in\_millisecond](#input\_parquet\_timestamp\_in\_millisecond) | Whether to output timestamp values in milliseconds for Parquet format. Default is false. | `bool` | `false` | no |
| <a name="input_parquet_version"></a> [parquet\_version](#input\_parquet\_version) | Version of Apache Parquet format. Valid values: parquet-1-0, parquet-2-0. Default is parquet-1-0. | `string` | `"parquet-1-0"` | no |
| <a name="input_preserve_transactions"></a> [preserve\_transactions](#input\_preserve\_transactions) | Whether to preserve transactions within the same file. Default is false. | `bool` | `false` | no |
| <a name="input_rfc_4180"></a> [rfc\_4180](#input\_rfc\_4180) | Whether to use RFC 4180 standard for CSV files. Default is true. | `bool` | `true` | no |
| <a name="input_s3_bucket_folder"></a> [s3\_bucket\_folder](#input\_s3\_bucket\_folder) | Folder path within the S3 bucket where DMS will store the migrated data. Optional. | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket where DMS will store the migrated data. | `string` | n/a | yes |
| <a name="input_server_side_encryption_kms_key_id"></a> [server\_side\_encryption\_kms\_key\_id](#input\_server\_side\_encryption\_kms\_key\_id) | KMS key ID or ARN for server-side encryption of S3 objects. Optional. | `string` | `null` | no |
| <a name="input_service_access_role_arn"></a> [service\_access\_role\_arn](#input\_service\_access\_role\_arn) | ARN of the IAM service access role used by DMS to access the S3 bucket. This role must have permissions to read/write to the specified S3 bucket. | `string` | n/a | yes |
| <a name="input_source_certificate_arn"></a> [source\_certificate\_arn](#input\_source\_certificate\_arn) | ARN of the source SSL certificate | `string` | `null` | no |
| <a name="input_source_endpoint_database_name"></a> [source\_endpoint\_database\_name](#input\_source\_endpoint\_database\_name) | Name of the source endpoint database. | `string` | `null` | no |
| <a name="input_source_endpoint_engine_name"></a> [source\_endpoint\_engine\_name](#input\_source\_endpoint\_engine\_name) | Type of engine for the source endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb, mysql, opensearch, oracle, postgres, sqlserver, sybase. | `string` | n/a | yes |
| <a name="input_source_endpoint_extra_connection_attributes"></a> [source\_endpoint\_extra\_connection\_attributes](#input\_source\_endpoint\_extra\_connection\_attributes) | Additional attributes associated with the source connection. | `string` | `null` | no |
| <a name="input_source_endpoint_id"></a> [source\_endpoint\_id](#input\_source\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_source_endpoint_kms_key_arn"></a> [source\_endpoint\_kms\_key\_arn](#input\_source\_endpoint\_kms\_key\_arn) | ARN for the KMS key that will be used to encrypt the connection parameters for source endpoint. | `string` | `null` | no |
| <a name="input_source_endpoint_password"></a> [source\_endpoint\_password](#input\_source\_endpoint\_password) | Password to be used to login to the source endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_port"></a> [source\_endpoint\_port](#input\_source\_endpoint\_port) | Port used by the source endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_server_name"></a> [source\_endpoint\_server\_name](#input\_source\_endpoint\_server\_name) | Host name of the source server. | `string` | n/a | yes |
| <a name="input_source_endpoint_service_access_role"></a> [source\_endpoint\_service\_access\_role](#input\_source\_endpoint\_service\_access\_role) | ARN used by the service access IAM role for dynamodb source endpoints. | `string` | `null` | no |
| <a name="input_source_endpoint_ssl_mode"></a> [source\_endpoint\_ssl\_mode](#input\_source\_endpoint\_ssl\_mode) | SSL mode to use for the source connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_source_endpoint_username"></a> [source\_endpoint\_username](#input\_source\_endpoint\_username) | User name to be used to login to the source endpoint database. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the DMS endpoints. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compression_type"></a> [compression\_type](#output\_compression\_type) | Compression type used by the DMS S3 endpoint |
| <a name="output_data_format"></a> [data\_format](#output\_data\_format) | Data format used by the DMS S3 endpoint |
| <a name="output_endpoint_arn"></a> [endpoint\_arn](#output\_endpoint\_arn) | ARN of the DMS S3 target endpoint |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | ID of the DMS S3 target endpoint |
| <a name="output_endpoint_type"></a> [endpoint\_type](#output\_endpoint\_type) | Type of the DMS endpoint |
| <a name="output_engine_display_name"></a> [engine\_display\_name](#output\_engine\_display\_name) | Engine display name of the DMS endpoint |
| <a name="output_s3_bucket_folder"></a> [s3\_bucket\_folder](#output\_s3\_bucket\_folder) | Folder path within the S3 bucket |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket used by the DMS endpoint |
| <a name="output_source_endpoint_arn"></a> [source\_endpoint\_arn](#output\_source\_endpoint\_arn) | ARN of the DMS source endpoint |
| <a name="output_source_endpoint_id"></a> [source\_endpoint\_id](#output\_source\_endpoint\_id) | ID of the DMS source endpoint |
| <a name="output_source_endpoint_type"></a> [source\_endpoint\_type](#output\_source\_endpoint\_type) | Type of the DMS source endpoint |
| <a name="output_source_engine_name"></a> [source\_engine\_name](#output\_source\_engine\_name) | Engine name of the DMS source endpoint |


<!-- END_TF_DOCS -->