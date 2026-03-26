<!-- BEGIN_TF_DOCS -->
AWS DocumentDB Cluster Instance
Terraform module which creates SAF2.0 DocumentDB Cluster Instance in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.1.0 |
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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_docdb_cluster_instance.cluster_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Specifies whether any database modifications are applied immediately, or during the next maintenance window. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The EC2 Availability Zone that the DB instance is created in. | `string` | `null` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The EC2 Availability Zone that the DB instance is created in. | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | The name of the database engine to be used for the DocDB instance. | `string` | `"docdb"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The identifier for the DocDB instance, if omitted, Terraform will assign a random, unique identifier. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class to use. | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to create. | `number` | `1` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00. | `string` | `null` | no |
| <a name="input_promotion_tier"></a> [promotion\_tier](#input\_promotion\_tier) | Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer. | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | aws\_docdb\_cluster\_instance provides the following Timeouts configuration options: create, update, delete. | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docdb_cluster_instance_arn"></a> [docdb\_cluster\_instance\_arn](#output\_docdb\_cluster\_instance\_arn) | Amazon Resource Name (ARN) of cluster instance. |
| <a name="output_docdb_cluster_instance_ca_cert_identifier"></a> [docdb\_cluster\_instance\_ca\_cert\_identifier](#output\_docdb\_cluster\_instance\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance. |
| <a name="output_docdb_cluster_instance_db_subnet_group_name"></a> [docdb\_cluster\_instance\_db\_subnet\_group\_name](#output\_docdb\_cluster\_instance\_db\_subnet\_group\_name) | The DB subnet group to associate with this DB instance. |
| <a name="output_docdb_cluster_instance_dbi_resource_id"></a> [docdb\_cluster\_instance\_dbi\_resource\_id](#output\_docdb\_cluster\_instance\_dbi\_resource\_id) | The region-unique, immutable identifier for the DB instance. |
| <a name="output_docdb_cluster_instance_endpoint"></a> [docdb\_cluster\_instance\_endpoint](#output\_docdb\_cluster\_instance\_endpoint) | The DNS address for this instance. May not be writable. |
| <a name="output_docdb_cluster_instance_engine"></a> [docdb\_cluster\_instance\_engine](#output\_docdb\_cluster\_instance\_engine) | The database engine. |
| <a name="output_docdb_cluster_instance_engine_version"></a> [docdb\_cluster\_instance\_engine\_version](#output\_docdb\_cluster\_instance\_engine\_version) | The database engine version. |
| <a name="output_docdb_cluster_instance_kms_key_id"></a> [docdb\_cluster\_instance\_kms\_key\_id](#output\_docdb\_cluster\_instance\_kms\_key\_id) | The ARN for the KMS encryption key if one is set to the cluster. |
| <a name="output_docdb_cluster_instance_port"></a> [docdb\_cluster\_instance\_port](#output\_docdb\_cluster\_instance\_port) | The database port. |
| <a name="output_docdb_cluster_instance_preferred_backup_window"></a> [docdb\_cluster\_instance\_preferred\_backup\_window](#output\_docdb\_cluster\_instance\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled. |
| <a name="output_docdb_cluster_instance_storage_encrypted"></a> [docdb\_cluster\_instance\_storage\_encrypted](#output\_docdb\_cluster\_instance\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. |
| <a name="output_docdb_cluster_instance_tags_all"></a> [docdb\_cluster\_instance\_tags\_all](#output\_docdb\_cluster\_instance\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_docdb_cluster_instance_writer"></a> [docdb\_cluster\_instance\_writer](#output\_docdb\_cluster\_instance\_writer) | Boolean indicating if this instance is writable. False indicates this instance is a read replica. |

<!-- END_TF_DOCS -->