<!-- BEGIN_TF_DOCS -->
AWS DocumentDB module
Terraform module which creates global\_cluster

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
| [aws_docdb_global_cluster.global_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_global_cluster) | resource |
| [aws_docdb_global_cluster.global_cluster_for_existing_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_global_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for an automatically created database on cluster creation. | `string` | `""` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the Global Cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Name of the database engine to be used for this DB cluster. Terraform will only perform drift detection if a configuration value is provided. Current Valid values: docdb. Defaults to docdb. Conflicts with source\_db\_cluster\_identifier. | `string` | `"docdb"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version of the global database. Upgrading the engine version will result in all cluster members being immediately updated and will. | `string` | `"4.0.0"` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | The global cluster identifier. | `string` | n/a | yes |
| <a name="input_source_db_cluster_identifier"></a> [source\_db\_cluster\_identifier](#input\_source\_db\_cluster\_identifier) | Amazon Resource Name (ARN) to use as the primary DB Cluster of the Global Cluster on creation. Terraform cannot perform drift detection of this value. | `string` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Global Cluster Amazon Resource Name (ARN) |
| <a name="output_arn_for_existing_cluster"></a> [arn\_for\_existing\_cluster](#output\_arn\_for\_existing\_cluster) | Global Cluster Amazon Resource Name (ARN) |
| <a name="output_global_cluster_members"></a> [global\_cluster\_members](#output\_global\_cluster\_members) | Set of objects containing Global Cluster members. |
| <a name="output_global_cluster_members_for_existing_cluster"></a> [global\_cluster\_members\_for\_existing\_cluster](#output\_global\_cluster\_members\_for\_existing\_cluster) | Set of objects containing Global Cluster members. |
| <a name="output_global_cluster_resource_id"></a> [global\_cluster\_resource\_id](#output\_global\_cluster\_resource\_id) | AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed. |
| <a name="output_global_cluster_resource_id_for_existing_cluster"></a> [global\_cluster\_resource\_id\_for\_existing\_cluster](#output\_global\_cluster\_resource\_id\_for\_existing\_cluster) | AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed. |
| <a name="output_id"></a> [id](#output\_id) | Attribute provides DocDB Global Cluster identifier that is created. |
| <a name="output_id_for_existing_cluster"></a> [id\_for\_existing\_cluster](#output\_id\_for\_existing\_cluster) | Attribute provides DocDB Global Cluster identifier that is created. |

<!-- END_TF_DOCS -->