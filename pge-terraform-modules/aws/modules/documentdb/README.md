<!-- BEGIN_TF_DOCS -->
# AWS DocumentDB Cluster
Terraform module which creates SAF2.0 DocumentDB Cluster in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.92.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |

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
| [aws_docdb_cluster.docdb_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_apply_immediately"></a> [cluster\_apply\_immediately](#input\_cluster\_apply\_immediately) | Specifies whether any cluster or database modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_cluster_availability_zones"></a> [cluster\_availability\_zones](#input\_cluster\_availability\_zones) | A list of EC2 Availability Zones that instances in the DB cluster can be created in. | `list(string)` | `[]` | no |
| <a name="input_cluster_backup_retention_period"></a> [cluster\_backup\_retention\_period](#input\_cluster\_backup\_retention\_period) | The days to retain backups for. | `number` | `15` | no |
| <a name="input_cluster_deletion_protection"></a> [cluster\_deletion\_protection](#input\_cluster\_deletion\_protection) | A value that indicates whether the DB cluster has deletion protection enabled. The database can't be deleted when deletion protection is enabled. | `bool` | `false` | no |
| <a name="input_cluster_enabled_cloudwatch_logs_exports"></a> [cluster\_enabled\_cloudwatch\_logs\_exports](#input\_cluster\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch. If omitted, no logs will be exported. | `list(string)` | <pre>[<br/>  "audit"<br/>]</pre> | no |
| <a name="input_cluster_engine"></a> [cluster\_engine](#input\_cluster\_engine) | The name of the database engine to be used for this DB cluster and instance. Defaults to docdb. | `string` | `"docdb"` | no |
| <a name="input_cluster_engine_version"></a> [cluster\_engine\_version](#input\_cluster\_engine\_version) | The database engine version. Updating this argument results in an outage. | `string` | `"4.0.0"` | no |
| <a name="input_cluster_final_snapshot_identifier"></a> [cluster\_final\_snapshot\_identifier](#input\_cluster\_final\_snapshot\_identifier) | The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made. | `string` | `null` | no |
| <a name="input_cluster_global_cluster_identifier"></a> [cluster\_global\_cluster\_identifier](#input\_cluster\_global\_cluster\_identifier) | The global cluster identifier. | `string` | `null` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The cluster identifier. If omitted, Terraform will assign a random, unique identifier. | `string` | n/a | yes |
| <a name="input_cluster_kms_key_id"></a> [cluster\_kms\_key\_id](#input\_cluster\_kms\_key\_id) | The ARN for the KMS encryption key. | `string` | n/a | yes |
| <a name="input_cluster_master_password"></a> [cluster\_master\_password](#input\_cluster\_master\_password) | (Required unless a snapshot\_identifier or unless a global\_cluster\_identifier is provided when the cluster is the 'secondary' cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. | `string` | `null` | no |
| <a name="input_cluster_master_username"></a> [cluster\_master\_username](#input\_cluster\_master\_username) | (Required unless a snapshot\_identifier or unless a global\_cluster\_identifier is provided when the cluster is the 'secondary' cluster of a global database) Username for the master DB user | `string` | `null` | no |
| <a name="input_cluster_port"></a> [cluster\_port](#input\_cluster\_port) | The port on which the DB accepts connections | `number` | `null` | no |
| <a name="input_cluster_preferred_backup_window"></a> [cluster\_preferred\_backup\_window](#input\_cluster\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region E.g., 04:00-09:00 | `string` | `null` | no |
| <a name="input_cluster_preferred_maintenance_window"></a> [cluster\_preferred\_maintenance\_window](#input\_cluster\_preferred\_maintenance\_window) | The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30 | `string` | `null` | no |
| <a name="input_cluster_skip_final_snapshot"></a> [cluster\_skip\_final\_snapshot](#input\_cluster\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final\_snapshot\_identifier. | `bool` | `false` | no |
| <a name="input_cluster_snapshot_identifier"></a> [cluster\_snapshot\_identifier](#input\_cluster\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot. | `string` | `null` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | aws\_docdb\_cluster provides the following Timeouts configuration options: create, update, delete | `map(string)` | `{}` | no |
| <a name="input_cluster_vpc_security_group_ids"></a> [cluster\_vpc\_security\_group\_ids](#input\_cluster\_vpc\_security\_group\_ids) | List of VPC security groups to associate with the Cluster | `list(string)` | n/a | yes |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | A cluster parameter group to associate with the cluster. | `string` | `null` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | A DB subnet group to associate with this DB instance. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docdb_cluster_arn"></a> [docdb\_cluster\_arn](#output\_docdb\_cluster\_arn) | Amazon Resource Name (ARN) of cluster. |
| <a name="output_docdb_cluster_cluster_members"></a> [docdb\_cluster\_cluster\_members](#output\_docdb\_cluster\_cluster\_members) | List of DocDB Instances that are a part of this cluster. |
| <a name="output_docdb_cluster_endpoint"></a> [docdb\_cluster\_endpoint](#output\_docdb\_cluster\_endpoint) | The DNS address of the DocDB instance. |
| <a name="output_docdb_cluster_hosted_zone_id"></a> [docdb\_cluster\_hosted\_zone\_id](#output\_docdb\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint. |
| <a name="output_docdb_cluster_id"></a> [docdb\_cluster\_id](#output\_docdb\_cluster\_id) | The DocDB Cluster Identifier. |
| <a name="output_docdb_cluster_reader_endpoint"></a> [docdb\_cluster\_reader\_endpoint](#output\_docdb\_cluster\_reader\_endpoint) | A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas. |
| <a name="output_docdb_cluster_resource_id"></a> [docdb\_cluster\_resource\_id](#output\_docdb\_cluster\_resource\_id) | The DocDB Cluster Resource ID. |
| <a name="output_docdb_cluster_tags_all"></a> [docdb\_cluster\_tags\_all](#output\_docdb\_cluster\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->