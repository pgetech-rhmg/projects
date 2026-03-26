 # AWS Elasticache-redis Terraform module

 Terraform base module for deploying and managing Elasticache-redis modules on Amazon Web Services (AWS). 

 Elasticache-redis Modules can be found at `elasticache-redis/modules/*`
 
 Elasti_Cache_Redis_Single_Node is located at `elasticache-redis/modules/elasticache-redis-single-node`

 Elasti_Cache_Redis_Multi_Node_Cluster is located at `elasticache-redis/modules/elasticache-redis-multinode-cluster`

 Elasti_Cache_Redis_Global_Replication_Group is located at `elasticache-redis/modules/elasticache-redis-global-replication-group`

 Elasti_Cache_Redis_Single_Node_With_Read_Replica is located at `elasticache-redis/modules/elasticache-redis-single-node`

 Elasticache-redis Modules examples can be found at `elasticache-redis/examples/*`
<!-- BEGIN_TF_DOCS -->
# AWS Elasticache-redis module
# Terraform module which creates SAF2.0 Elasticache-redis single node instance in AWS.
# Creates elasticache-redis single node instance with no replication.

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
| [aws_elasticache_cluster.redis_single_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_elasticache_parameter_group.paragroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_subnet_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether any database modifications are applied immediately, or during the next maintenance window.When you change an attribute, such as num\_cache\_nodes, by default it is applied in the next maintenance window. Because of this, Terraform may report a difference in its planning phase because the actual modification has not yet taken place. You can use the apply\_immediately flag to instruct the service to apply the change immediately. Using apply\_immediately can result in a brief downtime as the server reboots. | `bool` | `true` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Replication group identifier. This parameter is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_create_new_parametergroup"></a> [create\_new\_parametergroup](#input\_create\_new\_parametergroup) | Whether to create a new parameter group or use existing parameter group. | `bool` | `true` | no |
| <a name="input_engine_logs_log_delivery_destination"></a> [engine\_logs\_log\_delivery\_destination](#input\_engine\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Engine Log is supported for Redis cache clusters and replication groups using engine version 6.2 onward. | `string` | `null` | no |
| <a name="input_engine_logs_log_delivery_destination_type"></a> [engine\_logs\_log\_delivery\_destination\_type](#input\_engine\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | `"cloudwatch-logs"` | no |
| <a name="input_engine_logs_log_delivery_log_format"></a> [engine\_logs\_log\_delivery\_log\_format](#input\_engine\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | `"json"` | no |
| <a name="input_existing_parameter_group_name"></a> [existing\_parameter\_group\_name](#input\_existing\_parameter\_group\_name) | The name of the parameter group to associate with this cache cluster. valid: default.redis6.x | `string` | `null` | no |
| <a name="input_final_snapshot"></a> [final\_snapshot](#input\_final\_snapshot) | The name of your final snapshot when the replication group is deleted. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00 | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis | `string` | n/a | yes |
| <a name="input_notification_topic_arn"></a> [notification\_topic\_arn](#input\_notification\_topic\_arn) | ARN of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my\_sns\_topic | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of ElastiCache parameters to apply. | `list(map(string))` | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | The port number on which each of the cache nodes will accept connections. Redis the default port is 6379. | `number` | `6379` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine\_version\_actual. | `string` | n/a | yes |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | ID of the replication group to which this cluster should belong. If this parameter is specified, the cluster is added to the specified replication group as a read replica; otherwise, the cluster is a standalone primary that is not part of any replication group.Required if engine is not specified) | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | One or more VPC security groups associated with the cache cluster | `list(string)` | `null` | no |
| <a name="input_slow_logs_log_delivery_destination"></a> [slow\_logs\_log\_delivery\_destination](#input\_slow\_logs\_log\_delivery\_destination) | Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Slow Log is supported for Redis cache clusters and replication groups using engine version 6.0 onward. | `string` | `null` | no |
| <a name="input_slow_logs_log_delivery_destination_type"></a> [slow\_logs\_log\_delivery\_destination\_type](#input\_slow\_logs\_log\_delivery\_destination\_type) | For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose | `string` | `"cloudwatch-logs"` | no |
| <a name="input_slow_logs_log_delivery_log_format"></a> [slow\_logs\_log\_delivery\_log\_format](#input\_slow\_logs\_log\_delivery\_log\_format) | Valid values are json or text | `string` | `"json"` | no |
| <a name="input_snapshot_arns"></a> [snapshot\_arns](#input\_snapshot\_arns) | Single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. | `list(string)` | `null` | no |
| <a name="input_snapshot_name"></a> [snapshot\_name](#input\_snapshot\_name) | Name of a snapshot from which to restore data into the new node group. | `string` | `null` | no |
| <a name="input_snapshot_retention"></a> [snapshot\_retention](#input\_snapshot\_retention) | Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. snapshot\_retention\_limit is not supported on cache.t1.micro cache nodes | `number` | `15` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. Example: 05:00-09:00 | `string` | n/a | yes |
| <a name="input_subnet_group_description_redis"></a> [subnet\_group\_description\_redis](#input\_subnet\_group\_description\_redis) | Description for the cache subnet group. | `string` | `"Managed by Terraform"` | no |
| <a name="input_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#input\_subnet\_group\_subnet\_ids) | List of VPC Subnet IDs for the cache subnet group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the created ElastiCache Cluster |
| <a name="output_cache_nodes"></a> [cache\_nodes](#output\_cache\_nodes) | List of node objects |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | DNS name of the cache cluster without the port appended. |
| <a name="output_configuration_endpoint"></a> [configuration\_endpoint](#output\_configuration\_endpoint) | Configuration endpoint to allow host discovery. |
| <a name="output_engine_version_actual"></a> [engine\_version\_actual](#output\_engine\_version\_actual) | The running version of the cache engine. |
| <a name="output_parameter_group_arn"></a> [parameter\_group\_arn](#output\_parameter\_group\_arn) | The AWS ARN associated with the parameter group. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | The ElastiCache parameter group name. |
| <a name="output_parameter_group_tags_all"></a> [parameter\_group\_tags\_all](#output\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_subnet_group_description"></a> [subnet\_group\_description](#output\_subnet\_group\_description) | The Description of the ElastiCache Subnet Group. |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | The Name of the ElastiCache Subnet Group |
| <a name="output_subnet_group_subnet_ids"></a> [subnet\_group\_subnet\_ids](#output\_subnet\_group\_subnet\_ids) | The Subnet IDs of the ElastiCache Subnet Group |
| <a name="output_subnet_group_tags_all"></a> [subnet\_group\_tags\_all](#output\_subnet\_group\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider |

<!-- END_TF_DOCS -->