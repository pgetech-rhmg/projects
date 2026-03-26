<!-- BEGIN_TF_DOCS -->
# AWS DMS with S3 Target Endpoint Example
Terraform module which creates SAF2.0 DMS resources with S3 target endpoint in AWS.
This example shows how to configure DMS to migrate data to an S3 bucket

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
| <a name="module_dms_s3_access_role"></a> [dms\_s3\_access\_role](#module\_dms\_s3\_access\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_dms_s3_endpoints"></a> [dms\_s3\_endpoints](#module\_dms\_s3\_endpoints) | ../../modules/dms_endpoint_s3 | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.dms_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.dms_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Application ID for resource tagging | `string` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | CRIS number | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance requirements | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment (DEV, TEST, PROD, etc.) | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Notification contact | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order information | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | Resource owner | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_add_column_name"></a> [add\_column\_name](#input\_add\_column\_name) | Add column names to CSV files | `bool` | `true` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS IAM role | `string` | n/a | yes |
| <a name="input_csv_delimiter"></a> [csv\_delimiter](#input\_csv\_delimiter) | Delimiter for CSV files | `string` | `","` | no |
| <a name="input_csv_row_delimiter"></a> [csv\_row\_delimiter](#input\_csv\_row\_delimiter) | Row delimiter for CSV files | `string` | `"\\n"` | no |
| <a name="input_date_partition_sequence"></a> [date\_partition\_sequence](#input\_date\_partition\_sequence) | Date partition format sequence | `string` | `"YYYYMMDD"` | no |
| <a name="input_enable_date_partitioning"></a> [enable\_date\_partitioning](#input\_enable\_date\_partitioning) | Enable date-based partitioning in S3 for better data organization | `bool` | `true` | no |
| <a name="input_include_op_for_full_load"></a> [include\_op\_for\_full\_load](#input\_include\_op\_for\_full\_load) | Include operation columns for full load | `bool` | `false` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | Description for KMS key | `string` | `null` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Name for KMS key | `string` | `null` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS role for encryption | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional additional tags | `map(string)` | `{}` | no |
| <a name="input_s3_compression_type"></a> [s3\_compression\_type](#input\_s3\_compression\_type) | Compression type for S3 files. Options: NONE, GZIP | `string` | `"GZIP"` | no |
| <a name="input_s3_data_format"></a> [s3\_data\_format](#input\_s3\_data\_format) | Data format for S3 files. Options: csv, parquet | `string` | `"csv"` | no |
| <a name="input_s3_encryption_mode"></a> [s3\_encryption\_mode](#input\_s3\_encryption\_mode) | S3 server-side encryption mode | `string` | `"SSE_S3"` | no |
| <a name="input_s3_kms_key_id"></a> [s3\_kms\_key\_id](#input\_s3\_kms\_key\_id) | KMS key ID for S3 server-side encryption (required if encryption\_mode is SSE\_KMS or CSE\_KMS) | `string` | `null` | no |
| <a name="input_s3_target_bucket_arn"></a> [s3\_target\_bucket\_arn](#input\_s3\_target\_bucket\_arn) | ARN of the target S3 bucket | `string` | n/a | yes |
| <a name="input_s3_target_bucket_folder"></a> [s3\_target\_bucket\_folder](#input\_s3\_target\_bucket\_folder) | Folder path within S3 bucket for organizing data (e.g., 'psps-tahs/migration-data') | `string` | `"psps-tahs/migration-data"` | no |
| <a name="input_s3_target_bucket_name"></a> [s3\_target\_bucket\_name](#input\_s3\_target\_bucket\_name) | Name of the S3 bucket where DMS will store migrated data | `string` | n/a | yes |
| <a name="input_s3_target_endpoint_id"></a> [s3\_target\_endpoint\_id](#input\_s3\_target\_endpoint\_id) | S3 target endpoint identifier for psps-tahs team | `string` | n/a | yes |
| <a name="input_source_certificate_arn"></a> [source\_certificate\_arn](#input\_source\_certificate\_arn) | ARN of SSL certificate for source database | `string` | `null` | no |
| <a name="input_source_endpoint_database_name"></a> [source\_endpoint\_database\_name](#input\_source\_endpoint\_database\_name) | Source database name | `string` | n/a | yes |
| <a name="input_source_endpoint_engine_name"></a> [source\_endpoint\_engine\_name](#input\_source\_endpoint\_engine\_name) | Source database engine name (mysql, postgres, oracle, etc.) | `string` | n/a | yes |
| <a name="input_source_endpoint_extra_connection_attributes"></a> [source\_endpoint\_extra\_connection\_attributes](#input\_source\_endpoint\_extra\_connection\_attributes) | Additional connection attributes for the source endpoint | `string` | `null` | no |
| <a name="input_source_endpoint_id"></a> [source\_endpoint\_id](#input\_source\_endpoint\_id) | Source database endpoint identifier | `string` | n/a | yes |
| <a name="input_source_endpoint_port"></a> [source\_endpoint\_port](#input\_source\_endpoint\_port) | Source database port | `string` | n/a | yes |
| <a name="input_source_endpoint_server_name"></a> [source\_endpoint\_server\_name](#input\_source\_endpoint\_server\_name) | Source database server hostname | `string` | n/a | yes |
| <a name="input_source_endpoint_service_access_role"></a> [source\_endpoint\_service\_access\_role](#input\_source\_endpoint\_service\_access\_role) | ARN used by the service access IAM role for source endpoints (required for DynamoDB sources) | `string` | `null` | no |
| <a name="input_source_endpoint_ssl_mode"></a> [source\_endpoint\_ssl\_mode](#input\_source\_endpoint\_ssl\_mode) | SSL mode for source database connection | `string` | `"require"` | no |
| <a name="input_ssm_parameter_dms_password"></a> [ssm\_parameter\_dms\_password](#input\_ssm\_parameter\_dms\_password) | SSM Parameter name containing database password | `string` | n/a | yes |
| <a name="input_ssm_parameter_dms_username"></a> [ssm\_parameter\_dms\_username](#input\_ssm\_parameter\_dms\_username) | SSM Parameter name containing database username | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_format"></a> [data\_format](#output\_data\_format) | Data format used for S3 storage |
| <a name="output_dms_s3_service_role_arn"></a> [dms\_s3\_service\_role\_arn](#output\_dms\_s3\_service\_role\_arn) | ARN of the IAM role used by DMS to access S3 |
| <a name="output_dms_s3_service_role_name"></a> [dms\_s3\_service\_role\_name](#output\_dms\_s3\_service\_role\_name) | Name of the IAM role used by DMS to access S3 |
| <a name="output_s3_bucket_folder"></a> [s3\_bucket\_folder](#output\_s3\_bucket\_folder) | S3 bucket folder path |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name where data is stored |
| <a name="output_s3_target_endpoint_arn"></a> [s3\_target\_endpoint\_arn](#output\_s3\_target\_endpoint\_arn) | ARN of the DMS S3 target endpoint |
| <a name="output_s3_target_endpoint_id"></a> [s3\_target\_endpoint\_id](#output\_s3\_target\_endpoint\_id) | ID of the DMS S3 target endpoint |
| <a name="output_source_endpoint_arn"></a> [source\_endpoint\_arn](#output\_source\_endpoint\_arn) | ARN of the DMS source endpoint |
| <a name="output_source_endpoint_id"></a> [source\_endpoint\_id](#output\_source\_endpoint\_id) | ID of the DMS source endpoint |


<!-- END_TF_DOCS -->