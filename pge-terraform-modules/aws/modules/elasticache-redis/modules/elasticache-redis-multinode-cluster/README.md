<!-- BEGIN_TF_DOCS -->
# AWS Elasticache-redis module
Terraform module which creates SAF2.0 Elasticache-redis clusters in AWS.
Creates Elasticache redis multinode cluster enabled cluster with replication and data partitioning

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
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
| [aws_elasticache_parameter_group.paragroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.elasticache_replication_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether any database modifications are applied immediately, or during the next maintenance window.When you change an attribute, such as num\_cache\_nodes, by default it is applied in the next maintenance window. Because of this, Terraform may report a difference in its planning phase because the actual modification has not yet taken place. You can use the apply\_immediately flag to instruct the service to apply the change immediately. Using apply\_immediately can result in a brief downtime as the server reboots. | `bool` | `false` | no |
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Password used to access a password protected server.The 'auth\_token' has to be fetched from SSM Parameter store,which is a pre-requisite while using this module. | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Replication group identifier. This parameter is stored as a lowercase string. Changing this value will re-create the resource. | `string` | n/a | yes |
| <a name="input_cluster_on_parameters"></a> [cluster\_on\_parameters](#input\_cluster\_on\_parameters) | A list of ElastiCache parameters to apply. | `list(map(string))` | `[]` | no |
| <a name="input_create_new_parametergroup"></a> [create\_new\_parametergroup](#input\_create\_new\_parametergroup) | Whether to create a new parameter group or use existing parameter group. | `bool` | `true` | no |
| <a name="input_data_tiering_enabled"></a> [data\_tiering\_enabled](#input\_data\_tiering\_enabled) | Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type. This parameter must be set to true when using r6gd nodes. | `bool` | `null` | no |
| <a name="input_engine_logs_log_delivery_destination"></a> [engine\_logs\_log\_delivery\_destination](#input\_engine\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Engine Log is supported for Redis cache clusters and replication groups using engine version 6.2 onward. | `string` | `null` | no |
| <a name="input_engine_logs_log_delivery_destination_type"></a> [engine\_logs\_log\_delivery\_destination\_type](#input\_engine\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | `"cloudwatch-logs"` | no |
| <a name="input_engine_logs_log_delivery_log_format"></a> [engine\_logs\_log\_delivery\_log\_format](#input\_engine\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | `"json"` | no |
| <a name="input_existing_parameter_group_name"></a> [existing\_parameter\_group\_name](#input\_existing\_parameter\_group\_name) | The name of the parameter group to associate with this cache cluster. valid: default.redis6.x | `string` | `null` | no |
| <a name="input_final_snapshot"></a> [final\_snapshot](#input\_final\_snapshot) | The name of your final snapshot when the replication group is deleted. | `string` | n/a | yes |
| <a name="input_global_replication_group_id"></a> [global\_replication\_group\_id](#input\_global\_replication\_group\_id) | The ID of the global replication group to which this replication group should belong. If this parameter is specified, the replication group is added to the specified global replication group as a secondary replication group; otherwise, the replication group is not part of any global replication group. If global\_replication\_group\_id is set, the num\_node\_groups parameter (or the num\_node\_groups parameter of the deprecated cluster\_mode block) cannot be set. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the key that you wish to use if encrypting at rest. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00 | `string` | `null` | no |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | Specifies whether to enable Multi-AZ Support for the replication group. If true, automatic\_failover\_enabled must also be enabled. Defaults to false. | `bool` | `false` | no |
| <a name="input_nodetype"></a> [nodetype](#input\_nodetype) | Instance class to be used. | `string` | n/a | yes |
| <a name="input_notification_topic_arn"></a> [notification\_topic\_arn](#input\_notification\_topic\_arn) | ARN of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my\_sns\_topic | `string` | `null` | no |
| <a name="input_num_node_groups"></a> [num\_node\_groups](#input\_num\_node\_groups) | Number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications. Required unless global\_replication\_group\_id is set. | `string` | n/a | yes |
| <a name="input_port_number"></a> [port\_number](#input\_port\_number) | The port number on which each of the cache nodes will accept connections. Redis the default port is 6379. | `number` | `6379` | no |
| <a name="input_preferred_cache_cluster_azs"></a> [preferred\_cache\_cluster\_azs](#input\_preferred\_cache\_cluster\_azs) | List of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is considered. The first item in the list will be the primary node. Ignored when updating. | `list(string)` | `null` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine\_version\_actual. | `string` | n/a | yes |
| <a name="input_replicas_per_node_group"></a> [replicas\_per\_node\_group](#input\_replicas\_per\_node\_group) | Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | One or more Amazon VPC security groups associated with this replication group. Use this parameter only when you are creating a replication group in an Amazon Virtual Private Cloud | `list(string)` | `[]` | no |
| <a name="input_security_group_names"></a> [security\_group\_names](#input\_security\_group\_names) | List of cache security group names to associate with this replication group. | `list(string)` | `[]` | no |
| <a name="input_slow_logs_log_delivery_destination"></a> [slow\_logs\_log\_delivery\_destination](#input\_slow\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Slow Log is supported for Redis cache clusters and replication groups using engine version 6.0 onward. | `string` | `null` | no |
| <a name="input_slow_logs_log_delivery_destination_type"></a> [slow\_logs\_log\_delivery\_destination\_type](#input\_slow\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | `"cloudwatch-logs"` | no |
| <a name="input_slow_logs_log_delivery_log_format"></a> [slow\_logs\_log\_delivery\_log\_format](#input\_slow\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | `"json"` | no |
| <a name="input_snapshot_arns"></a> [snapshot\_arns](#input\_snapshot\_arns) | List of ARNs that identify Redis RDB snapshot files stored in Amazon S3. The names object names cannot contain any commas. | `list(string)` | `[]` | no |
| <a name="input_snapshot_name"></a> [snapshot\_name](#input\_snapshot\_name) | Name of a snapshot from which to restore data into the new node group. Changing the snapshot\_name forces a new resource. | `string` | `null` | no |
| <a name="input_snapshot_retention"></a> [snapshot\_retention](#input\_snapshot\_retention) | Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. | `number` | `15` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00 | `string` | `null` | no |
| <a name="input_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#input\_subnet\_group\_subnet\_ids) | List of VPC Subnet IDs for the cache subnet group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_timeouts_create"></a> [timeouts\_create](#input\_timeouts\_create) | How long to wait for a replication group to be created. | `string` | `"120m"` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | How long to wait for a replication group to be deleted. | `string` | `"80m"` | no |
| <a name="input_timeouts_update"></a> [timeouts\_update](#input\_timeouts\_update) | How long to wait for replication group settings to be updated. This is also separately used for adding/removing replicas and online resize operation completion, if necessary. | `string` | `"80m"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter_group_arn"></a> [parameter\_group\_arn](#output\_parameter\_group\_arn) | The AWS ARN associated with the parameter group. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | The ElastiCache parameter group name. |
| <a name="output_parameter_group_tags_all"></a> [parameter\_group\_tags\_all](#output\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_replication_group_arn"></a> [replication\_group\_arn](#output\_replication\_group\_arn) | ARN of the created ElastiCache Replication Group. |
| <a name="output_replication_group_cluster_enabled"></a> [replication\_group\_cluster\_enabled](#output\_replication\_group\_cluster\_enabled) | Indicates if cluster mode is enabled. |
| <a name="output_replication_group_configuration_endpoint_address"></a> [replication\_group\_configuration\_endpoint\_address](#output\_replication\_group\_configuration\_endpoint\_address) | Address of the replication group configuration endpoint when cluster mode is enabled. |
| <a name="output_replication_group_engine_version_actual"></a> [replication\_group\_engine\_version\_actual](#output\_replication\_group\_engine\_version\_actual) | Running version of the cache engine. |
| <a name="output_replication_group_id"></a> [replication\_group\_id](#output\_replication\_group\_id) | ID of the ElastiCache Replication Group. |
| <a name="output_replication_group_member_clusters"></a> [replication\_group\_member\_clusters](#output\_replication\_group\_member\_clusters) | Identifiers of all the nodes that are part of this replication group. |
| <a name="output_replication_group_primary_endpoint_address"></a> [replication\_group\_primary\_endpoint\_address](#output\_replication\_group\_primary\_endpoint\_address) | Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled. |
| <a name="output_replication_group_reader_endpoint_address"></a> [replication\_group\_reader\_endpoint\_address](#output\_replication\_group\_reader\_endpoint\_address) | Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled. |
| <a name="output_replication_group_tags_all"></a> [replication\_group\_tags\_all](#output\_replication\_group\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_subnet_group_description"></a> [subnet\_group\_description](#output\_subnet\_group\_description) | The Description of the ElastiCache Subnet Group. |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | The Name of the ElastiCache Subnet Group |
| <a name="output_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#output\_subnet\_group\_subnet\_ids) | The Subnet IDs of the ElastiCache Subnet Group |
| <a name="output_subnet_group_tags_all"></a> [subnet\_group\_tags\_all](#output\_subnet\_group\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->