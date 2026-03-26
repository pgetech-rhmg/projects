<!-- BEGIN_TF_DOCS -->
# AWS Glue Partition Index module.
Terraform module which creates SAF2.0 Glue Partition Index in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_glue_partition_index.glue_partition_index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_partition_index) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_partition_catalog_id"></a> [partition\_catalog\_id](#input\_partition\_catalog\_id) | The catalog ID where the table resides. | `string` | `null` | no |
| <a name="input_partition_database_name"></a> [partition\_database\_name](#input\_partition\_database\_name) | Name of the metadata database where the table metadata resides. For Hive compatibility, this must be all lowercase. | `string` | n/a | yes |
| <a name="input_partition_index"></a> [partition\_index](#input\_partition\_index) | Configuration block for a partition index. | `list(any)` | n/a | yes |
| <a name="input_partition_table_name"></a> [partition\_table\_name](#input\_partition\_table\_name) | Name of the table. For Hive compatibility, this must be entirely lowercase. | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | set timeouts for partition\_index | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_partition_index"></a> [aws\_glue\_partition\_index](#output\_aws\_glue\_partition\_index) | The map of aws\_glue\_partition\_index. |
| <a name="output_partition_index_id"></a> [partition\_index\_id](#output\_partition\_index\_id) | Catalog ID, Database name,table name, and index name. |


<!-- END_TF_DOCS -->