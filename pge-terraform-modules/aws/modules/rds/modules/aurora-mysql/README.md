<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_db_cluster"></a> [db\_cluster](#module\_db\_cluster) | ../../ | n/a |
| <a name="module_db_cluster_instance"></a> [db\_cluster\_instance](#module\_db\_cluster\_instance) | ../internal/db_cluster_instance | n/a |
| <a name="module_db_cluster_parameter_group"></a> [db\_cluster\_parameter\_group](#module\_db\_cluster\_parameter\_group) | ../internal/db_cluster_parameter_group | n/a |
| <a name="module_db_parameter_group"></a> [db\_parameter\_group](#module\_db\_parameter\_group) | ../internal/db_parameter_group | n/a |
| <a name="module_db_subnet_group"></a> [db\_subnet\_group](#module\_db\_subnet\_group) | ../internal/db_subnet_group | n/a |
| <a name="module_main_security_group"></a> [main\_security\_group](#module\_main\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_ssm_parameter"></a> [ssm\_parameter](#module\_ssm\_parameter) | app.terraform.io/pgetech/ssm/aws | 0.1.2 |
| <a name="module_validate-pge-tags"></a> [validate-pge-tags](#module\_validate-pge-tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions_alarm"></a> [actions\_alarm](#input\_actions\_alarm) | A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_actions_ok"></a> [actions\_ok](#input\_actions\_ok) | A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | (Optional) The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster). | `string` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | (Optional) Enable to allow major engine version upgrades when changing engine versions. Defaults to false. | `bool` | `false` | no |
| <a name="input_anomaly_band_width"></a> [anomaly\_band\_width](#input\_anomaly\_band\_width) | The width of the anomaly band, default 2.  Higher numbers means less sensitive. | `string` | `"2"` | no |
| <a name="input_anomaly_period"></a> [anomaly\_period](#input\_anomaly\_period) | The number of seconds that make each evaluation period for anomaly detection. | `string` | `"600"` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | (Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional, Computed, Forces new resource) The EC2 Availability Zone that the DB instance is created in. See docs about the details. | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional) A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply. It is recommended to specify 3 AZs or use the lifecycle configuration block ignore\_changes argument if necessary. | `list(string)` | n/a | yes |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | (Optional) The days to retain backups for. Default 15 | `number` | `15` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | (Optional) The identifier of the CA certificate for the DB instance. | `string` | `null` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Configuration block for egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | `[]` | no |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | Configuration block for ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_instance_count"></a> [cluster\_instance\_count](#input\_cluster\_instance\_count) | Number of instances to create. | `number` | `1` | no |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | A list of DB cluster parameter maps to apply.  Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-cluster-parameters after initial creation of the group. | `list(map(string))` | `[]` | no |
| <a name="input_cluster_performance_insights_enabled"></a> [cluster\_performance\_insights\_enabled](#input\_cluster\_performance\_insights\_enabled) | (Optional) Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_cluster_performance_insights_kms_key_id"></a> [cluster\_performance\_insights\_kms\_key\_id](#input\_cluster\_performance\_insights\_kms\_key\_id) | (Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `null` | no |
| <a name="input_cluster_performance_insights_retention_period"></a> [cluster\_performance\_insights\_retention\_period](#input\_cluster\_performance\_insights\_retention\_period) | (Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance\_insights\_retention\_period, performance\_insights\_enabled needs to be set to true. Defaults to '7'. | `number` | `7` | no |
| <a name="input_cpu_credit_balance_too_low_threshold"></a> [cpu\_credit\_balance\_too\_low\_threshold](#input\_cpu\_credit\_balance\_too\_low\_threshold) | Alarm threshold for the 'lowCPUCreditBalance' alarm | `string` | `"100"` | no |
| <a name="input_cpu_utilization_too_high_threshold"></a> [cpu\_utilization\_too\_high\_threshold](#input\_cpu\_utilization\_too\_high\_threshold) | Alarm threshold for the 'highCPUUtilization' alarm | `string` | `"90"` | no |
| <a name="input_create_anomaly_alarm"></a> [create\_anomaly\_alarm](#input\_create\_anomaly\_alarm) | Whether or not to create the fairly noisy anomaly alarm.  Default is to create it (for backwards compatible support), but recommended to disable this for non-production databases | `bool` | `true` | no |
| <a name="input_create_ssm_parameter"></a> [create\_ssm\_parameter](#input\_create\_ssm\_parameter) | (Optional) Whether to create SSM parameter for the master password. Default is false. | `bool` | `false` | no |
| <a name="input_custom_instance_names"></a> [custom\_instance\_names](#input\_custom\_instance\_names) | (Optional) List of custom names for cluster instances. If provided, the list length must match cluster\_instance\_count. If not provided, defaults to identifier-0, identifier-1, etc. for backward compatibility. | `list(string)` | `[]` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Optional) Name for an automatically created database on cluster creation. Must be lowercase alphanumeric(There are different naming restrictions per database engine: RDS Naming Constraints). | `string` | `null` | no |
| <a name="input_db_cluster_instance_tags"></a> [db\_cluster\_instance\_tags](#input\_db\_cluster\_instance\_tags) | Additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_cluster_parameter_group_tags"></a> [db\_cluster\_parameter\_group\_tags](#input\_db\_cluster\_parameter\_group\_tags) | Additional tags for the  DB cluster parameter group | `map(string)` | `{}` | no |
| <a name="input_db_parameter_group_tags"></a> [db\_parameter\_group\_tags](#input\_db\_parameter\_group\_tags) | A mapping of tags to assign to the db parameter group resource. | `map(string)` | `{}` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | A mapping of tags to assign to the db subnet group resource. | `map(string)` | `{}` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | `bool` | `false` | no |
| <a name="input_disk_burst_balance_too_low_threshold"></a> [disk\_burst\_balance\_too\_low\_threshold](#input\_disk\_burst\_balance\_too\_low\_threshold) | Alarm threshold for the lowEBSBurstBalance alarm | `string` | `"100"` | no |
| <a name="input_disk_free_storage_space_too_low_threshold"></a> [disk\_free\_storage\_space\_too\_low\_threshold](#input\_disk\_free\_storage\_space\_too\_low\_threshold) | Alarm threshold for the lowFreeStorageSpace alarm | `string` | `"10000000000"` | no |
| <a name="input_disk_queue_depth_too_high_threshold"></a> [disk\_queue\_depth\_too\_high\_threshold](#input\_disk\_queue\_depth\_too\_high\_threshold) | Alarm threshold for the highDiskQueueDepth alarm | `string` | `"64"` | no |
| <a name="input_enable_global_write_forwarding"></a> [enable\_global\_write\_forwarding](#input\_enable\_global\_write\_forwarding) | (Optional) Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an aws\_rds\_global\_cluster's primary cluster. See the Aurora Userguide documentation for more information. | `bool` | `null` | no |
| <a name="input_enable_http_endpoint"></a> [enable\_http\_endpoint](#input\_enable\_http\_endpoint) | (Optional) Enable HTTP endpoint (data API). Only valid when engine\_mode is set to serverless. | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL). | `list(string)` | <pre>[<br>  "audit",<br>  "error",<br>  "general",<br>  "slowquery"<br>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters). | `string` | `"aurora-mysql"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | (Optional) The database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), multimaster, parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless. | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value. For example with Aurora MySQL 2, a potential value for this argument is 5.7.mysql\_aurora.2.03.2. The value can contain a partial version where supported by the API. The actual engine version used is returned in the attribute engine\_version\_actual, , see Attributes Reference below. | `string` | `null` | no |
| <a name="input_evaluation_period"></a> [evaluation\_period](#input\_evaluation\_period) | The evaluation period over which to use when triggering alarms. | `string` | `"5"` | no |
| <a name="input_family"></a> [family](#input\_family) | The family of the DB parameter group | `string` | `null` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | (Optional) The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made. | `string` | `null` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | (Optional) The global cluster identifier specified on aws\_rds\_global\_cluster. | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Optional, Forces new resource) The identifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details.? | `string` | n/a | yes |
| <a name="input_instance_timeouts"></a> [instance\_timeouts](#input\_instance\_timeouts) | (Optional) Updated Terraform resource management timeouts. Applies to aws\_db\_cluster\_instance. | `map(string)` | <pre>{<br>  "create": "90m",<br>  "delete": "90m",<br>  "update": "90m"<br>}</pre> | no |
| <a name="input_iops"></a> [iops](#input\_iops) | (Optional) The amount of provisioned IOPS. Setting this implies a storage\_type of io1. | `number` | `null` | no |
| <a name="input_key_id"></a> [key\_id](#input\_key\_id) | KMS key ID or ARN for encrypting a SecureString. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key. When specifying kms\_key\_id, storage\_encrypted needs to be set to true. | `string` | n/a | yes |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided | `bool` | `false` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. | `string` | `null` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | The ARN for the KMS encryption key for manage master user password. If creating an encrypted replica, set this to the destination KMS ARN. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | (Required unless a snapshot\_identifier or replication\_source\_identifier is provided or unless a global\_cluster\_identifier is provided when the cluster is the secondary cluster of a global database) Username for the master DB user. Please refer to the RDS Naming Constraints. This argument does not support in-place updates and cannot be changed during a restore from snapshot. | `string` | `null` | no |
| <a name="input_memory_freeable_too_low_threshold"></a> [memory\_freeable\_too\_low\_threshold](#input\_memory\_freeable\_too\_low\_threshold) | Alarm threshold for the lowFreeableMemory alarm | `string` | `"256000000"` | no |
| <a name="input_memory_swap_usage_too_high_threshold"></a> [memory\_swap\_usage\_too\_high\_threshold](#input\_memory\_swap\_usage\_too\_high\_threshold) | Alarm threshold for the highSwapUsage alarm | `string` | `"256000000"` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | (Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `1` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | (Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the AWS Documentation what IAM permissions are needed to allow Enhanced Monitoring for RDS Instances. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of DB parameter maps to apply. | `list(map(string))` | `[]` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | (Optional) Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | (Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | (Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance\_insights\_retention\_period, performance\_insights\_enabled needs to be set to true. Defaults to 7. | `number` | `7` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00 | `string` | `null` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | (Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30 | `string` | `null` | no |
| <a name="input_promotion_tier"></a> [promotion\_tier](#input\_promotion\_tier) | (Optional) Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer. | `number` | `0` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | (Optional) Length of random password to create. (default: 16) | `number` | `16` | no |
| <a name="input_replication_source_identifier"></a> [replication\_source\_identifier](#input\_replication\_source\_identifier) | (Optional) ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. If DB Cluster is part of a Global Cluster, use the lifecycle configuration block ignore\_changes argument to prevent Terraform from showing differences for this argument instead of configuring this value. | `string` | `null` | no |
| <a name="input_scaling_configuration"></a> [scaling\_configuration](#input\_scaling\_configuration) | (Optional) Map of nested attribute with scaling properties. Only valid when engine\_mode is set to serverless. | `map(string)` | `{}` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Configuration block for for nested security groups egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br>    from                     = number<br>    to                       = number<br>    protocol                 = string<br>    source_security_group_id = string<br>    description              = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br>    from                     = number<br>    to                       = number<br>    protocol                 = string<br>    source_security_group_id = string<br>    description              = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags for the RDS security group | `map(string)` | `{}` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | (Optional) Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned` | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final\_snapshot\_identifier. Default is false. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | (Optional) Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot. | `string` | `null` | no |
| <a name="input_source_region"></a> [source\_region](#input\_source\_region) | (Optional) The source region for an encrypted replica DB cluster. | `string` | `null` | no |
| <a name="input_ssm_description"></a> [ssm\_description](#input\_ssm\_description) | Description of the parameter | `string` | `null` | no |
| <a name="input_statistic_period"></a> [statistic\_period](#input\_statistic\_period) | The number of seconds that make each statistic period. | `string` | `"60"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | (Optional) Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: io1, Default: io1. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of VPC subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the DB cluster. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomalous_connection_count_metric_alarm_arn"></a> [anomalous\_connection\_count\_metric\_alarm\_arn](#output\_anomalous\_connection\_count\_metric\_alarm\_arn) | The ARN of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_anomalous_connection_count_metric_alarm_id"></a> [anomalous\_connection\_count\_metric\_alarm\_id](#output\_anomalous\_connection\_count\_metric\_alarm\_id) | The ID of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_aurora-mysql-all"></a> [aurora-mysql-all](#output\_aurora-mysql-all) | A list of map of all the outputs from the aurora-mysql module |
| <a name="output_cluster_master_user_secret"></a> [cluster\_master\_user\_secret](#output\_cluster\_master\_user\_secret) | The generated database master user secret when `manage_master_user_password` is set to `true` |
| <a name="output_cpu_utilization_too_high_metric_alarm_arn"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_arn](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_arn) | The ARN of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_cpu_utilization_too_high_metric_alarm_id"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_id](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_id) | The ID of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_db_cluster_arn"></a> [db\_cluster\_arn](#output\_db\_cluster\_arn) | The ARN of the db cluster. |
| <a name="output_db_cluster_availability_zones"></a> [db\_cluster\_availability\_zones](#output\_db\_cluster\_availability\_zones) | The availability zone of the instance. |
| <a name="output_db_cluster_backup_retention_period"></a> [db\_cluster\_backup\_retention\_period](#output\_db\_cluster\_backup\_retention\_period) | The backup retention period. |
| <a name="output_db_cluster_cluster_identifier"></a> [db\_cluster\_cluster\_identifier](#output\_db\_cluster\_cluster\_identifier) | The RDS Cluster Identifier. |
| <a name="output_db_cluster_cluster_members"></a> [db\_cluster\_cluster\_members](#output\_db\_cluster\_cluster\_members) | List of RDS Instances that are a part of this cluster. |
| <a name="output_db_cluster_cluster_resource_id"></a> [db\_cluster\_cluster\_resource\_id](#output\_db\_cluster\_cluster\_resource\_id) | The RDS Cluster Resource ID. |
| <a name="output_db_cluster_database_name"></a> [db\_cluster\_database\_name](#output\_db\_cluster\_database\_name) | The database name. |
| <a name="output_db_cluster_endpoint"></a> [db\_cluster\_endpoint](#output\_db\_cluster\_endpoint) | The DNS address of the RDS instance. |
| <a name="output_db_cluster_engine"></a> [db\_cluster\_engine](#output\_db\_cluster\_engine) | The database engine. |
| <a name="output_db_cluster_engine_version_actual"></a> [db\_cluster\_engine\_version\_actual](#output\_db\_cluster\_engine\_version\_actual) | The running version of the database. |
| <a name="output_db_cluster_hosted_zone_id"></a> [db\_cluster\_hosted\_zone\_id](#output\_db\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint. |
| <a name="output_db_cluster_id"></a> [db\_cluster\_id](#output\_db\_cluster\_id) | The RDS Cluster Identifier. |
| <a name="output_db_cluster_instance_arn"></a> [db\_cluster\_instance\_arn](#output\_db\_cluster\_instance\_arn) | Amazon Resource Name (ARN) of cluster instance. |
| <a name="output_db_cluster_instance_availability_zone"></a> [db\_cluster\_instance\_availability\_zone](#output\_db\_cluster\_instance\_availability\_zone) | TThe availability zone of the instance. |
| <a name="output_db_cluster_instance_cluster_identifier"></a> [db\_cluster\_instance\_cluster\_identifier](#output\_db\_cluster\_instance\_cluster\_identifier) | The RDS Cluster Identifier. |
| <a name="output_db_cluster_instance_dbi_resource_id"></a> [db\_cluster\_instance\_dbi\_resource\_id](#output\_db\_cluster\_instance\_dbi\_resource\_id) | The region-unique, immutable identifier for the DB instance. |
| <a name="output_db_cluster_instance_endpoint"></a> [db\_cluster\_instance\_endpoint](#output\_db\_cluster\_instance\_endpoint) | The DNS address for this instance. May not be writable. |
| <a name="output_db_cluster_instance_engine"></a> [db\_cluster\_instance\_engine](#output\_db\_cluster\_instance\_engine) | The database engine. |
| <a name="output_db_cluster_instance_engine_version_actual"></a> [db\_cluster\_instance\_engine\_version\_actual](#output\_db\_cluster\_instance\_engine\_version\_actual) | The database engine version. |
| <a name="output_db_cluster_instance_id"></a> [db\_cluster\_instance\_id](#output\_db\_cluster\_instance\_id) | The Instance identifier. |
| <a name="output_db_cluster_instance_identifier"></a> [db\_cluster\_instance\_identifier](#output\_db\_cluster\_instance\_identifier) | The Instance identifier. |
| <a name="output_db_cluster_instance_kms_key_id"></a> [db\_cluster\_instance\_kms\_key\_id](#output\_db\_cluster\_instance\_kms\_key\_id) | The ARN for the KMS encryption key if one is set to the cluster. |
| <a name="output_db_cluster_instance_performance_insights_enabled"></a> [db\_cluster\_instance\_performance\_insights\_enabled](#output\_db\_cluster\_instance\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. |
| <a name="output_db_cluster_instance_performance_insights_kms_key_id"></a> [db\_cluster\_instance\_performance\_insights\_kms\_key\_id](#output\_db\_cluster\_instance\_performance\_insights\_kms\_key\_id) | The ARN for the KMS encryption key used by Performance Insights. |
| <a name="output_db_cluster_instance_port"></a> [db\_cluster\_instance\_port](#output\_db\_cluster\_instance\_port) | The database port. |
| <a name="output_db_cluster_instance_storage_encrypted"></a> [db\_cluster\_instance\_storage\_encrypted](#output\_db\_cluster\_instance\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. |
| <a name="output_db_cluster_instance_tags_all"></a> [db\_cluster\_instance\_tags\_all](#output\_db\_cluster\_instance\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_db_cluster_instance_writer"></a> [db\_cluster\_instance\_writer](#output\_db\_cluster\_instance\_writer) | Boolean indicating if this instance is writable. False indicates this instance is a read replica. |
| <a name="output_db_cluster_master_username"></a> [db\_cluster\_master\_username](#output\_db\_cluster\_master\_username) | The master username for the database. |
| <a name="output_db_cluster_parameter_group_arn"></a> [db\_cluster\_parameter\_group\_arn](#output\_db\_cluster\_parameter\_group\_arn) | The ARN of the db cluster parameter group. |
| <a name="output_db_cluster_parameter_group_id"></a> [db\_cluster\_parameter\_group\_id](#output\_db\_cluster\_parameter\_group\_id) | The db cluster parameter group id. |
| <a name="output_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#output\_db\_cluster\_parameter\_group\_name) | Name of the db cluster parameter group. |
| <a name="output_db_cluster_parameter_group_tags_all"></a> [db\_cluster\_parameter\_group\_tags\_all](#output\_db\_cluster\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_db_cluster_port"></a> [db\_cluster\_port](#output\_db\_cluster\_port) | The database port. |
| <a name="output_db_cluster_preferred_backup_window"></a> [db\_cluster\_preferred\_backup\_window](#output\_db\_cluster\_preferred\_backup\_window) | The daily time range during which the backups happen. |
| <a name="output_db_cluster_preferred_maintenance_window"></a> [db\_cluster\_preferred\_maintenance\_window](#output\_db\_cluster\_preferred\_maintenance\_window) | The maintenance window. |
| <a name="output_db_cluster_reader_endpoint"></a> [db\_cluster\_reader\_endpoint](#output\_db\_cluster\_reader\_endpoint) | A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas. |
| <a name="output_db_cluster_replication_source_identifier"></a> [db\_cluster\_replication\_source\_identifier](#output\_db\_cluster\_replication\_source\_identifier) | ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica. |
| <a name="output_db_cluster_storage_encrypted"></a> [db\_cluster\_storage\_encrypted](#output\_db\_cluster\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. |
| <a name="output_db_cluster_tags_all"></a> [db\_cluster\_tags\_all](#output\_db\_cluster\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block.. |
| <a name="output_db_parameter_group_arn"></a> [db\_parameter\_group\_arn](#output\_db\_parameter\_group\_arn) | The ARN of the db parameter group |
| <a name="output_db_parameter_group_id"></a> [db\_parameter\_group\_id](#output\_db\_parameter\_group\_id) | The db parameter group name. |
| <a name="output_db_subnet_group_arn"></a> [db\_subnet\_group\_arn](#output\_db\_subnet\_group\_arn) | The ARN of the db subnet group |
| <a name="output_db_subnet_group_id"></a> [db\_subnet\_group\_id](#output\_db\_subnet\_group\_id) | The db subnet group name |
| <a name="output_disk_burst_balance_too_low_metric_alarm_arn"></a> [disk\_burst\_balance\_too\_low\_metric\_alarm\_arn](#output\_disk\_burst\_balance\_too\_low\_metric\_alarm\_arn) | The ARN of the disk\_burst\_balance\_too\_low cloudwatch metric alarm |
| <a name="output_disk_burst_balance_too_low_metric_alarm_id"></a> [disk\_burst\_balance\_too\_low\_metric\_alarm\_id](#output\_disk\_burst\_balance\_too\_low\_metric\_alarm\_id) | The ID of the disk\_burst\_balance\_too\_low cloudwatch metric alarm |
| <a name="output_disk_free_storage_space_too_low_metric_alarm_arn"></a> [disk\_free\_storage\_space\_too\_low\_metric\_alarm\_arn](#output\_disk\_free\_storage\_space\_too\_low\_metric\_alarm\_arn) | The ARN of the disk\_free\_storage\_space\_too\_low cloudwatch metric alarm |
| <a name="output_disk_free_storage_space_too_low_metric_alarm_id"></a> [disk\_free\_storage\_space\_too\_low\_metric\_alarm\_id](#output\_disk\_free\_storage\_space\_too\_low\_metric\_alarm\_id) | The ID of the disk\_free\_storage\_space\_too\_low cloudwatch metric alarm |
| <a name="output_disk_queue_depth_too_high_metric_alarm_arn"></a> [disk\_queue\_depth\_too\_high\_metric\_alarm\_arn](#output\_disk\_queue\_depth\_too\_high\_metric\_alarm\_arn) | The ARN of the disk\_queue\_depth\_too\_high cloudwatch metric alarm |
| <a name="output_disk_queue_depth_too_high_metric_alarm_id"></a> [disk\_queue\_depth\_too\_high\_metric\_alarm\_id](#output\_disk\_queue\_depth\_too\_high\_metric\_alarm\_id) | The ID of the disk\_queue\_depth\_too\_high cloudwatch metric alarm |
| <a name="output_memory_freeable_too_low_metric_alarm_arn"></a> [memory\_freeable\_too\_low\_metric\_alarm\_arn](#output\_memory\_freeable\_too\_low\_metric\_alarm\_arn) | The ARN of the memory\_freeable\_too\_low cloudwatch metric alarm |
| <a name="output_memory_freeable_too_low_metric_alarm_id"></a> [memory\_freeable\_too\_low\_metric\_alarm\_id](#output\_memory\_freeable\_too\_low\_metric\_alarm\_id) | The ID of the memory\_freeable\_too\_low cloudwatch metric alarm |
| <a name="output_memory_swap_usage_too_high_metric_alarm_arn"></a> [memory\_swap\_usage\_too\_high\_metric\_alarm\_arn](#output\_memory\_swap\_usage\_too\_high\_metric\_alarm\_arn) | The ARN of the memory\_swap\_usage\_too\_high cloudwatch metric alarm |
| <a name="output_memory_swap_usage_too_high_metric_alarm_id"></a> [memory\_swap\_usage\_too\_high\_metric\_alarm\_id](#output\_memory\_swap\_usage\_too\_high\_metric\_alarm\_id) | The ID of the memory\_swap\_usage\_too\_high cloudwatch metric alarm |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | security group name |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | security group id |
| <a name="output_ssm_param_db_generated_master_password_arn"></a> [ssm\_param\_db\_generated\_master\_password\_arn](#output\_ssm\_param\_db\_generated\_master\_password\_arn) | The ARN of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_type"></a> [ssm\_param\_db\_generated\_master\_password\_type](#output\_ssm\_param\_db\_generated\_master\_password\_type) | The type of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_value"></a> [ssm\_param\_db\_generated\_master\_password\_value](#output\_ssm\_param\_db\_generated\_master\_password\_value) | The value of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_version"></a> [ssm\_param\_db\_generated\_master\_password\_version](#output\_ssm\_param\_db\_generated\_master\_password\_version) | The version of the parameter storing the generated db master password. |
| <a name="output_ssm_param_ddb_generated_master_password_name"></a> [ssm\_param\_ddb\_generated\_master\_password\_name](#output\_ssm\_param\_ddb\_generated\_master\_password\_name) | The name of the parameter storing the generated db master password. |


<!-- END_TF_DOCS -->