<!-- BEGIN_TF_DOCS -->
# AWS Glue Catalog Database module.
Terraform module which creates SAF2.0 Glue Catalog Database in AWS.

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
| [aws_glue_catalog_database.glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | ID of the Glue Catalog to create the database in. If omitted, this defaults to the AWS Account ID | `string` | `null` | no |
| <a name="input_create_table_default_permission"></a> [create\_table\_default\_permission](#input\_create\_table\_default\_permission) | Creates a set of default permissions on the table for principals. | `list(any)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the database | `string` | `null` | no |
| <a name="input_location_uri"></a> [location\_uri](#input\_location\_uri) | Location of the database (for example, an HDFS path) | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the database. The acceptable characters are lowercase letters, numbers, and the underscore character | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of key-value pairs that define parameters and properties of the database | `map(string)` | `{}` | no |
| <a name="input_target_database"></a> [target\_database](#input\_target\_database) | Configuration block for a target database for resource linking. | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Glue Catalog Database |
| <a name="output_aws_glue_catalog_database"></a> [aws\_glue\_catalog\_database](#output\_aws\_glue\_catalog\_database) | Map of aws\_glue\_catalog\_database object |
| <a name="output_id"></a> [id](#output\_id) | Catalog ID and name of the database |
| <a name="output_name"></a> [name](#output\_name) | Catalog ID, Database name and of the name table |


<!-- END_TF_DOCS -->