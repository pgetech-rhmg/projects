AWS redshift Terraform module
Terraform base module for deploying and managing redshift modules () on Amazon Web Services (AWS).

redshift Modules can be found at redshift/modules/*

redshift Modules examples can be found at redshift/examples/*
<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| [aws_redshift_cluster.Cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster) | resource |
| [aws_redshift_logging.Cluster_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_logging) | resource |
| [aws_redshift_snapshot_copy.snapshot_copy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_snapshot_copy) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aqua_configuration_status"></a> [aqua\_configuration\_status](#input\_aqua\_configuration\_status) | The value represents how the cluster is configured to use AQUA (Advanced Query Accelerator) after the cluster is restored. | `string` | `null` | no |
| <a name="input_automated_snapshot_retention_period"></a> [automated\_snapshot\_retention\_period](#input\_automated\_snapshot\_retention\_period) | The number of days that automated snapshots are retained. If the value is 0, automated snapshots are disabled. Even if automated snapshots are disabled, you can still create manual snapshots when you want with create-cluster-snapshot. Default is 1. | `number` | `15` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The Cluster Identifier. Must be a lower case string. | `string` | n/a | yes |
| <a name="input_cluster_parameter_group_name"></a> [cluster\_parameter\_group\_name](#input\_cluster\_parameter\_group\_name) | The name of the parameter group to be associated with this cluster. | `string` | `null` | no |
| <a name="input_cluster_subnet_group_name"></a> [cluster\_subnet\_group\_name](#input\_cluster\_subnet\_group\_name) | The name of a cluster subnet group to be associated with this cluster. If this parameter is not provided the resulting cluster will be deployed outside virtual private cloud (VPC). | `string` | n/a | yes |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | The cluster type to use. Either single-node or multi-node | `string` | `null` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The version of the Amazon Redshift engine software that you want to deploy on the cluster. The version selected runs on all the nodes in the cluster. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The name of the first database to be created when the cluster is created. If you do not provide a name, Amazon Redshift will create a default database called dev. | `string` | `null` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | The identifier of the final snapshot that is to be created immediately before deleting the cluster. | `string` | `null` | no |
| <a name="input_iam_role_arns"></a> [iam\_role\_arns](#input\_iam\_role\_arns) | A list of IAM Role ARNs to associate with the cluster. A Maximum of 10 can be associated to the cluster at any time. | `list(string)` | `[]` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | (Optional) A list of IAM Role ARNs to associate with the cluster. | `list(string)` | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key. | `string` | n/a | yes |
| <a name="input_maintenance_track_name"></a> [maintenance\_track\_name](#input\_maintenance\_track\_name) | The name of the maintenance track for the restored cluster. | `string` | `null` | no |
| <a name="input_manual_snapshot_retention_period"></a> [manual\_snapshot\_retention\_period](#input\_manual\_snapshot\_retention\_period) | The default number of days to retain a manual snapshot. | `number` | `15` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Password must contain at least 8 chars and contain at least one uppercase letter, one lowercase letter, and one number. | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The node type to be provisioned for the cluster. | `string` | n/a | yes |
| <a name="input_number_of_nodes"></a> [number\_of\_nodes](#input\_number\_of\_nodes) | The number of compute nodes in the cluster. | `number` | `null` | no |
| <a name="input_owner_account"></a> [owner\_account](#input\_owner\_account) | The AWS customer account used to create or copy the snapshot. | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | The port number on which the cluster accepts incoming connections. Valid values are between 1115 and 65535. | `number` | `5439` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The weekly time range (in UTC) during which automated cluster maintenance can occur. Format: ddd:hh24:mi-ddd:hh24:mi | `string` | `null` | no |
| <a name="input_redshift_availability_zone"></a> [redshift\_availability\_zone](#input\_redshift\_availability\_zone) | availability\_zone:<br/>   The EC2 Availability Zone (AZ) in which you want Amazon Redshift to provision the cluster. For example, if you have several EC2 instances running in a specific Availability Zone, then you might want the cluster to be provisioned in the same zone in order to decrease network latency. Can only be changed if availability\_zone\_relocation\_enabled is true.<br/>availability\_zone\_relocation\_enabled:<br/>   If true, the cluster can be relocated to another availabity zone, either automatically by AWS or when requested. Default is false. Available for use on clusters from the RA3 instance family. | <pre>object({<br/>    availability_zone_relocation_enabled = bool<br/>    availability_zone                    = string<br/>  })</pre> | <pre>{<br/>  "availability_zone": null,<br/>  "availability_zone_relocation_enabled": false<br/>}</pre> | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix applied to the log file names. | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster. | `bool` | `null` | no |
| <a name="input_snapshot_cluster_identifier"></a> [snapshot\_cluster\_identifier](#input\_snapshot\_cluster\_identifier) | The name of the cluster the source snapshot was created from. | `string` | `null` | no |
| <a name="input_snapshot_copy"></a> [snapshot\_copy](#input\_snapshot\_copy) | n/a | <pre>map(object({<br/>    destination_region       = string<br/>    retention_period         = number<br/>    snapshot_copy_grant_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | The name of the snapshot from which to create the new cluster. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster. | `list(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_cluster_all"></a> [aws\_redshift\_cluster\_all](#output\_aws\_redshift\_cluster\_all) | A map of aws redshift cluster attribute references |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster. |
| <a name="output_cluster_automated_snapshot_retention_period"></a> [cluster\_automated\_snapshot\_retention\_period](#output\_cluster\_automated\_snapshot\_retention\_period) | The backup retention period. |
| <a name="output_cluster_availability_zone"></a> [cluster\_availability\_zone](#output\_cluster\_availability\_zone) | The availability zone of the Cluster. |
| <a name="output_cluster_cluster_identifier"></a> [cluster\_cluster\_identifier](#output\_cluster\_cluster\_identifier) | The Cluster Identifier. |
| <a name="output_cluster_cluster_nodes"></a> [cluster\_cluster\_nodes](#output\_cluster\_cluster\_nodes) | The nodes in the cluster. Cluster node blocks are documented below. |
| <a name="output_cluster_cluster_parameter_group_name"></a> [cluster\_cluster\_parameter\_group\_name](#output\_cluster\_cluster\_parameter\_group\_name) | The name of the parameter group to be associated with this cluster. |
| <a name="output_cluster_cluster_public_key"></a> [cluster\_cluster\_public\_key](#output\_cluster\_cluster\_public\_key) | The public key for the cluster. |
| <a name="output_cluster_cluster_revision_number"></a> [cluster\_cluster\_revision\_number](#output\_cluster\_cluster\_revision\_number) | The specific revision number of the database in the cluster. |
| <a name="output_cluster_cluster_subnet_group_name"></a> [cluster\_cluster\_subnet\_group\_name](#output\_cluster\_cluster\_subnet\_group\_name) | The name of a cluster subnet group to be associated with this cluster. |
| <a name="output_cluster_cluster_type"></a> [cluster\_cluster\_type](#output\_cluster\_cluster\_type) | The cluster type. |
| <a name="output_cluster_cluster_version"></a> [cluster\_cluster\_version](#output\_cluster\_cluster\_version) | The version of Redshift engine software. |
| <a name="output_cluster_database_name"></a> [cluster\_database\_name](#output\_cluster\_database\_name) | The name of the default database in the Cluster. |
| <a name="output_cluster_dns_name"></a> [cluster\_dns\_name](#output\_cluster\_dns\_name) | The DNS name of the cluster. |
| <a name="output_cluster_encrypted"></a> [cluster\_encrypted](#output\_cluster\_encrypted) | Whether the data in the cluster is encrypted. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The connection endpoint. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The Redshift Cluster ID. |
| <a name="output_cluster_node_type"></a> [cluster\_node\_type](#output\_cluster\_node\_type) | The type of nodes in the cluster. |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The Port the cluster responds on. |
| <a name="output_cluster_preferred_maintenance_window"></a> [cluster\_preferred\_maintenance\_window](#output\_cluster\_preferred\_maintenance\_window) | The backup window. |
| <a name="output_cluster_tags_all"></a> [cluster\_tags\_all](#output\_cluster\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_cluster_vpc_security_group_ids"></a> [cluster\_vpc\_security\_group\_ids](#output\_cluster\_vpc\_security\_group\_ids) | The VPC security group Ids associated with the cluster. |
| <a name="output_redshift_logging"></a> [redshift\_logging](#output\_redshift\_logging) | A map of all attributes of aws redshift logging |
| <a name="output_redshift_snapshot_copy"></a> [redshift\_snapshot\_copy](#output\_redshift\_snapshot\_copy) | A map of all attributes of aws redshift snapshot copy |

<!-- END_TF_DOCS -->