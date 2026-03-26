<!-- BEGIN_TF_DOCS -->
Athena Workgroup with New Glue Example

Description:
  Demonstrates deployment of the base Athena workgroup
  module composed with the optional Glue submodule.

  This example provisions:
    - Athena workgroup (configured with an existing S3 bucket for query results via `output_location`)
    - Glue database
    - Glue external table

  Intended to show a complete Athena + Glue
  integration pattern.

Example Path:
  aws/modules/athena/examples/athena\_glue

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

No providers.

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
| <a name="module_athena"></a> [athena](#module\_athena) | ../../ | n/a |
| <a name="module_athena_glue"></a> [athena\_glue](#module\_athena\_glue) | ../../modules/glue | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Application ID tag used for resource identification. | `string` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | CRIS identifier used for compliance, governance, and tracking. | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance frameworks or standards applicable to this resource. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level applied for compliance and governance. | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment tag indicating deployment stage (e.g., Dev, QA, Prod). | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | List of email addresses or contacts to notify for resource events. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order or priority tag used for resource grouping and sorting. | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List of owners responsible for the lifecycle of this resource. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | Name of the Athena Workgroup to be created. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be deployed. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | IAM role name used for assuming into the target AWS account. | `string` | n/a | yes |
| <a name="input_columns"></a> [columns](#input\_columns) | List of column definitions for the Glue table schema, including name and data type. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_data_bucket"></a> [data\_bucket](#input\_data\_bucket) | S3 bucket containing the data for the Glue table. | `string` | n/a | yes |
| <a name="input_data_prefix"></a> [data\_prefix](#input\_data\_prefix) | S3 prefix (folder path) where the Glue table data resides. | `string` | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | Name of the Glue database to create or reference. | `string` | n/a | yes |
| <a name="input_glue_table_name"></a> [glue\_table\_name](#input\_glue\_table\_name) | Name of the Glue table to create or reference. | `string` | n/a | yes |
| <a name="input_output_location"></a> [output\_location](#input\_output\_location) | S3 path where Athena query results will be stored (e.g., s3://bucket/prefix/). | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->