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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
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
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_db_cloudwatch_metric_alarms"></a> [db\_cloudwatch\_metric\_alarms](#module\_db\_cloudwatch\_metric\_alarms) | ../internal/db_cloudwatch_metric_alarms | n/a |
| <a name="module_db_instance"></a> [db\_instance](#module\_db\_instance) | ../internal/db_instance | n/a |
| <a name="module_db_option_group"></a> [db\_option\_group](#module\_db\_option\_group) | ../internal/db_option_group | n/a |
| <a name="module_db_parameter_group"></a> [db\_parameter\_group](#module\_db\_parameter\_group) | ../internal/db_parameter_group | n/a |
| <a name="module_db_subnet_group"></a> [db\_subnet\_group](#module\_db\_subnet\_group) | ../internal/db_subnet_group | n/a |
| <a name="module_main_security_group"></a> [main\_security\_group](#module\_main\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_ssm_parameter"></a> [ssm\_parameter](#module\_ssm\_parameter) | app.terraform.io/pgetech/ssm/aws | 0.1.2 |
| <a name="module_validate-pge-tags"></a> [validate-pge-tags](#module\_validate-pge-tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance_role_association.s3_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance_role_association) | resource |
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions_alarm"></a> [actions\_alarm](#input\_actions\_alarm) | A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_actions_ok"></a> [actions\_ok](#input\_actions\_ok) | A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gigabytes.   (Required unless a snapshot\_identifier or replicate\_source\_db is provided) The allocated storage in gibibytes. If max\_allocated\_storage is configured, this argument represents the initial storage allocation and differences from the configuration will be ignored automatically when Storage Autoscaling occurs. If replicate\_source\_db is set, the value is ignored during the creation of the instance. | `string` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible | `bool` | `false` | no |
| <a name="input_anomaly_band_width"></a> [anomaly\_band\_width](#input\_anomaly\_band\_width) | The width of the anomaly band, default 2.  Higher numbers means less sensitive. | `string` | `"2"` | no |
| <a name="input_anomaly_period"></a> [anomaly\_period](#input\_anomaly\_period) | The number of seconds that make each evaluation period for anomaly detection. | `string` | `"600"` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The Availability Zone of the RDS instance | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain backups for | `number` | `15` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance\_window | `string` | `null` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_character_set_name"></a> [character\_set\_name](#input\_character\_set\_name) | (Optional) The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation. | `string` | `null` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Configuration block for egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | `[]` | no |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | Configuration block for ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | `[]` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | On delete, copy all Instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_cpu_credit_balance_too_low_threshold"></a> [cpu\_credit\_balance\_too\_low\_threshold](#input\_cpu\_credit\_balance\_too\_low\_threshold) | Alarm threshold for the 'lowCPUCreditBalance' alarm | `string` | `"100"` | no |
| <a name="input_cpu_utilization_too_high_threshold"></a> [cpu\_utilization\_too\_high\_threshold](#input\_cpu\_utilization\_too\_high\_threshold) | Alarm threshold for the 'highCPUUtilization' alarm | `string` | `"90"` | no |
| <a name="input_create_iam_role_association"></a> [create\_iam\_role\_association](#input\_create\_iam\_role\_association) | Create IAM role association for S3 integration | `bool` | `false` | no |
| <a name="input_create_low_disk_burst_alarm"></a> [create\_low\_disk\_burst\_alarm](#input\_create\_low\_disk\_burst\_alarm) | Whether or not to create the low disk burst alarm.  Default is to create it (for backwards compatible support) | `bool` | `true` | no |
| <a name="input_create_ssm_parameter"></a> [create\_ssm\_parameter](#input\_create\_ssm\_parameter) | (Optional) Whether to create SSM parameter for the master password. Default is false. | `bool` | `false` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | Additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The DB name to create. If omitted, no database is created initially.  For SQL Server, this variable may need to be set to null. | `string` | `null` | no |
| <a name="input_db_option_group_tags"></a> [db\_option\_group\_tags](#input\_db\_option\_group\_tags) | Additional tags for the DB option group | `map(string)` | `{}` | no |
| <a name="input_db_parameter_group_tags"></a> [db\_parameter\_group\_tags](#input\_db\_parameter\_group\_tags) | Additional tags for the  DB parameter group | `map(string)` | `{}` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | Additional tags for the DB subnet group | `map(string)` | `{}` | no |
| <a name="input_delete_automated_backups"></a> [delete\_automated\_backups](#input\_delete\_automated\_backups) | Specifies whether to remove automated backups immediately after the DB instance is deleted | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | The database can't be deleted when this value is set to true. | `bool` | `false` | no |
| <a name="input_disk_burst_balance_too_low_threshold"></a> [disk\_burst\_balance\_too\_low\_threshold](#input\_disk\_burst\_balance\_too\_low\_threshold) | Alarm threshold for the 'lowEBSBurstBalance' alarm | `string` | `"100"` | no |
| <a name="input_disk_free_storage_space_too_low_threshold"></a> [disk\_free\_storage\_space\_too\_low\_threshold](#input\_disk\_free\_storage\_space\_too\_low\_threshold) | Alarm threshold for the 'lowFreeStorageSpace' alarm | `string` | `"10000000000"` | no |
| <a name="input_disk_queue_depth_too_high_threshold"></a> [disk\_queue\_depth\_too\_high\_threshold](#input\_disk\_queue\_depth\_too\_high\_threshold) | Alarm threshold for the 'highDiskQueueDepth' alarm | `string` | `"64"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The ID of the Directory Service Active Directory domain to create the instance in | `string` | `null` | no |
| <a name="input_domain_iam_role_name"></a> [domain\_iam\_role\_name](#input\_domain\_iam\_role\_name) | The name of the IAM role to be used when making API calls to the Directory Service | `string` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine). MySQL and MariaDB: audit, error, general, slowquery. PostgreSQL: postgresql, upgrade. MSSQL: agent , error. Oracle: alert, audit, listener, trace. | `list(string)` | <pre>[<br>  "agent",<br>  "error"<br>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) The database engine to use. For supported values, see the Engine parameter in API action CreateDBInstance. Cannot be specified for a replica. Note that for Amazon Aurora instances the engine must match the DB cluster's engine'. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version to use. If auto\_minor\_version\_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the attribute engine\_version\_actual.  Note that for Amazon Aurora instances the engine version must match the DB cluster's engine version'. Cannot be specified for a replica. | `string` | `null` | no |
| <a name="input_evaluation_period"></a> [evaluation\_period](#input\_evaluation\_period) | The evaluation period over which to use when triggering alarms. | `string` | `"5"` | no |
| <a name="input_family"></a> [family](#input\_family) | The family of the DB parameter group | `string` | `null` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip\_final\_snapshot is set to false. The value must begin with a letter, only contain alphanumeric characters and hyphens, and not end with a hyphen or contain two consecutive hyphens. Must not be provided when deleting a read replica. | `string` | `null` | no |
| <a name="input_final_snapshot_identifier_prefix"></a> [final\_snapshot\_identifier\_prefix](#input\_final\_snapshot\_identifier\_prefix) | The name which is prefixed to the final snapshot on cluster destroy | `string` | `"final"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS instance | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1' | `number` | `0` | no |
| <a name="input_key_id"></a> [key\_id](#input\_key\_id) | KMS key ID or ARN for encrypting a SecureString. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. | `string` | n/a | yes |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | License model information for this DB instance. Optional, but required for some DB engines, i.e. Oracle SE1 | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00' | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided | `bool` | `false` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | The ARN for the KMS encryption key for manage master user password. If creating an encrypted replica, set this to the destination KMS ARN. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. | `number` | `0` | no |
| <a name="input_memory_freeable_too_low_threshold"></a> [memory\_freeable\_too\_low\_threshold](#input\_memory\_freeable\_too\_low\_threshold) | Alarm threshold for the 'lowFreeableMemory' alarm | `string` | `"256000000"` | no |
| <a name="input_memory_swap_usage_too_high_threshold"></a> [memory\_swap\_usage\_too\_high\_threshold](#input\_memory\_swap\_usage\_too\_high\_threshold) | Alarm threshold for the 'highSwapUsage' alarm | `string` | `"256000000"` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `1` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring\_interval is non-zero. | `string` | n/a | yes |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_option_group_timeouts"></a> [option\_group\_timeouts](#input\_option\_group\_timeouts) | Define maximum timeout for deletion of `aws_db_option_group` resource | `map(string)` | <pre>{<br>  "delete": "35m"<br>}</pre> | no |
| <a name="input_options"></a> [options](#input\_options) | A list of DB options to apply with an option group. Depends on DB engine | <pre>list(object({<br>    db_security_group_memberships  = list(string)<br>    option_name                    = string<br>    port                           = number<br>    version                        = string<br>    vpc_security_group_memberships = list(string)<br><br>    option_settings = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of DB parameter maps to apply | `list(map(string))` | `[]` | no |
| <a name="input_password"></a> [password](#input\_password) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights are enabled | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections | `string` | `1433` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Bool to control if instance is publicly accessible | `bool` | `false` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | (Optional) Length of random password to create. (default: 16) | `number` | `16` | no |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate. | `string` | `null` | no |
| <a name="input_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#input\_restore\_to\_point\_in\_time) | Restore to a point in time. This setting does not apply to aurora-mysql or aurora-postgresql. | `map(string)` | `null` | no |
| <a name="input_rotation_after_days"></a> [rotation\_after\_days](#input\_rotation\_after\_days) | A structure that defines the rotation configuration for this secret | `number` | `89` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | Existing S3 bucket name for RDS export/import | `string` | `""` | no |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | `true` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Configuration block for for nested security groups egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br>    from                     = number<br>    to                       = number<br>    protocol                 = string<br>    source_security_group_id = string<br>    description              = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br>    from                     = number<br>    to                       = number<br>    protocol                 = string<br>    source_security_group_id = string<br>    description              = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags for the RDS security group | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final\_snapshot\_identifier | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | `string` | `null` | no |
| <a name="input_statistic_period"></a> [statistic\_period](#input\_statistic\_period) | The number of seconds that make each statistic period. | `string` | `"60"` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB instance is encrypted.  Note that if you are creating a cross-region read replica this field is ignored and you should instead declare kms\_key\_id with a valid ARN. The default is false if not specified. | `bool` | `true` | no |
| <a name="input_storage_throughput"></a> [storage\_throughput](#input\_storage\_throughput) | (Optional) The storage throughput value for the DB instance. Can only be set when storage\_type is 'gp3'. Cannot be specified if the allocated\_storage value is below a per-engine threshold. See the RDS User Guide for details. | `number` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of VPC subnet IDs | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times | `map(string)` | <pre>{<br>  "create": "90m",<br>  "delete": "90m",<br>  "update": "90m"<br>}</pre> | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | (Optional) Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation. See MSSQL User Guide for more information. | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for the master DB user | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomalous_connection_count_metric_alarm_arn"></a> [anomalous\_connection\_count\_metric\_alarm\_arn](#output\_anomalous\_connection\_count\_metric\_alarm\_arn) | The ARN of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_anomalous_connection_count_metric_alarm_id"></a> [anomalous\_connection\_count\_metric\_alarm\_id](#output\_anomalous\_connection\_count\_metric\_alarm\_id) | The ID of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_cpu_utilization_too_high_metric_alarm_arn"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_arn](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_arn) | The ARN of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_cpu_utilization_too_high_metric_alarm_id"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_id](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_id) | The ID of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The address of the RDS instance. |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS instance. |
| <a name="output_db_instance_availability_zone"></a> [db\_instance\_availability\_zone](#output\_db\_instance\_availability\_zone) | The availability zone of the RDS instance. |
| <a name="output_db_instance_ca_cert_identifier"></a> [db\_instance\_ca\_cert\_identifier](#output\_db\_instance\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance. |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The connection endpoint. |
| <a name="output_db_instance_host"></a> [db\_instance\_host](#output\_db\_instance\_host) | The RDS address. |
| <a name="output_db_instance_hosted_zone_id"></a> [db\_instance\_hosted\_zone\_id](#output\_db\_instance\_hosted\_zone\_id) | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record). |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The RDS instance ID. |
| <a name="output_db_instance_identifier"></a> [db\_instance\_identifier](#output\_db\_instance\_identifier) | The identifier of the DB instance |
| <a name="output_db_instance_master_password"></a> [db\_instance\_master\_password](#output\_db\_instance\_master\_password) | The master password. |
| <a name="output_db_instance_master_user_secret"></a> [db\_instance\_master\_user\_secret](#output\_db\_instance\_master\_user\_secret) | The ARN of the master user secret (Only available when manage\_master\_user\_password is set to true) |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | The database name. |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The database port. |
| <a name="output_db_instance_resource_id"></a> [db\_instance\_resource\_id](#output\_db\_instance\_resource\_id) | The RDS Resource ID of this instance. |
| <a name="output_db_instance_status"></a> [db\_instance\_status](#output\_db\_instance\_status) | The RDS instance status. |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | The master username for the database. |
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
| <a name="output_sqlserver_all"></a> [sqlserver\_all](#output\_sqlserver\_all) | A list of map of all sqlserver module attributes |
| <a name="output_ssm_param_db_generated_master_password_arn"></a> [ssm\_param\_db\_generated\_master\_password\_arn](#output\_ssm\_param\_db\_generated\_master\_password\_arn) | The ARN of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_type"></a> [ssm\_param\_db\_generated\_master\_password\_type](#output\_ssm\_param\_db\_generated\_master\_password\_type) | The type of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_value"></a> [ssm\_param\_db\_generated\_master\_password\_value](#output\_ssm\_param\_db\_generated\_master\_password\_value) | The value of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_version"></a> [ssm\_param\_db\_generated\_master\_password\_version](#output\_ssm\_param\_db\_generated\_master\_password\_version) | The version of the parameter storing the generated db master password. |
| <a name="output_ssm_param_ddb_generated_master_password_name"></a> [ssm\_param\_ddb\_generated\_master\_password\_name](#output\_ssm\_param\_ddb\_generated\_master\_password\_name) | The name of the parameter storing the generated db master password. |


<!-- END_TF_DOCS -->