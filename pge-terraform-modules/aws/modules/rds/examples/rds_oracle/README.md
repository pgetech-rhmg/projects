<!-- BEGIN_TF_DOCS -->
# RDS Oracle module
Terraform module which creates SAF2.0 Oracle RDS Database.
Pre-Requisites:
   1. Directory Service and it's domain are shared within your account.  Your security group egress cidr should reflect the VPC of the Managed AD account.
   2. IAM Role rds-directoryservice-kerberos-access-role exists within your account (should be automatically deployed to PG&E accounts).If not available work with respective team in PG&E.
   3. S3 integration requires an s3 bucket has been previously created and the arn passed in this module as a variable
   4. S3 key must exist/ uploaded to S3 bucket before running the module
   5. To have automated replication, multi region KMS must be created before running the module
   6. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds\_vpc\_endpoint example module (rds/examples/rds\_vpc\_endpoint)
   7. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

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
| <a name="module_oracle_rds"></a> [oracle\_rds](#module\_oracle\_rds) | ../../modules/oracle | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_directory_service_directory.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/directory_service_directory) | data source |
| [aws_iam_role.rds_managed_ad](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_ssm_parameter.private_subnet1_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.private_subnet2_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.private_subnet3_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_cidr_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_cidr_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_actions_alarm"></a> [actions\_alarm](#input\_actions\_alarm) | A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_actions_ok"></a> [actions\_ok](#input\_actions\_ok) | A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution. | `list(any)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gigabytes | `string` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `true` | no |
| <a name="input_autostart"></a> [autostart](#input\_autostart) | Set it to yes if auto start needs to be enabled | `map(any)` | <pre>{<br>  "autostart": "no"<br>}</pre> | no |
| <a name="input_autostop"></a> [autostop](#input\_autostop) | Set it to yes if auto stop needs to be enabled | `map(any)` | <pre>{<br>  "autostop": "no"<br>}</pre> | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The Availability Zone of the RDS instance | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | Unique name for the role | `string` | n/a | yes |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain backups for | `number` | `15` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance\_window | `string` | `null` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_character_set_name"></a> [character\_set\_name](#input\_character\_set\_name) | (Optional) The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation. | `string` | `null` | no |
| <a name="input_cpu_credit_balance_too_low_threshold"></a> [cpu\_credit\_balance\_too\_low\_threshold](#input\_cpu\_credit\_balance\_too\_low\_threshold) | Alarm threshold for the 'lowCPUCreditBalance' alarm | `string` | `"100"` | no |
| <a name="input_cpu_utilization_too_high_threshold"></a> [cpu\_utilization\_too\_high\_threshold](#input\_cpu\_utilization\_too\_high\_threshold) | Alarm threshold for the highCPUUtilization alarm | `string` | `"90"` | no |
| <a name="input_create_low_disk_burst_alarm"></a> [create\_low\_disk\_burst\_alarm](#input\_create\_low\_disk\_burst\_alarm) | Whether or not to create the low disk burst alarm.  Default is to create it (for backwards compatible support) | `bool` | `true` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | Additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The DB name to create. If omitted, no database is created initially.  The Oracle System ID (SID) of the created DB instance. If you specify null, the default value ORCL is used. You can't specify the string NULL, or any other reserved word, for DBName.  Can't be longer than 8 characters | `string` | `"ORCL"` | no |
| <a name="input_db_option_group_tags"></a> [db\_option\_group\_tags](#input\_db\_option\_group\_tags) | Additional tags for the DB option group | `map(string)` | `{}` | no |
| <a name="input_db_parameter_group_tags"></a> [db\_parameter\_group\_tags](#input\_db\_parameter\_group\_tags) | Additional tags for the  DB parameter group | `map(string)` | `{}` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | Additional tags for the DB subnet group | `map(string)` | `{}` | no |
| <a name="input_delete_automated_backups"></a> [delete\_automated\_backups](#input\_delete\_automated\_backups) | Specifies whether to remove automated backups immediately after the DB instance is deleted | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | The database can't be deleted when this value is set to true. | `bool` | `false` | no |
| <a name="input_disk_burst_balance_too_low_threshold"></a> [disk\_burst\_balance\_too\_low\_threshold](#input\_disk\_burst\_balance\_too\_low\_threshold) | Alarm threshold for the lowEBSBurstBalance alarm | `string` | `"100"` | no |
| <a name="input_disk_free_storage_space_too_low_threshold"></a> [disk\_free\_storage\_space\_too\_low\_threshold](#input\_disk\_free\_storage\_space\_too\_low\_threshold) | Alarm threshold for the lowFreeStorageSpace alarm | `string` | `"10000000000"` | no |
| <a name="input_disk_queue_depth_too_high_threshold"></a> [disk\_queue\_depth\_too\_high\_threshold](#input\_disk\_queue\_depth\_too\_high\_threshold) | Alarm threshold for the highDiskQueueDepth alarm | `string` | `"64"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The ID of the Directory Service Active Directory domain to create the instance in | `string` | n/a | yes |
| <a name="input_domain_iam_role_name"></a> [domain\_iam\_role\_name](#input\_domain\_iam\_role\_name) | (Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service | `string` | `"rds-directoryservice-kerberos-access-role"` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values for Oracle: trace, audit, alert, listener | `list(string)` | <pre>[<br>  "trace",<br>  "audit",<br>  "alert",<br>  "listener"<br>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) The database engine to use. For supported values, see the Engine parameter in API action CreateDBInstance. Cannot be specified for a replica. Note that for Amazon Aurora instances the engine must match the DB cluster's engine. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide. | `string` | `null` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version to use. If auto\_minor\_version\_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the attribute engine\_version\_actual.  Note that for Amazon Aurora instances the engine version must match the DB cluster's engine version. Cannot be specified for a replica. | `string` | `null` | no |
| <a name="input_evaluation_period"></a> [evaluation\_period](#input\_evaluation\_period) | The evaluation period over which to use when triggering alarms. | `string` | `"5"` | no |
| <a name="input_family"></a> [family](#input\_family) | The family of the DB parameter group | `string` | `null` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip\_final\_snapshot is set to false. The value must begin with a letter, only contain alphanumeric characters and hyphens, and not end with a hyphen or contain two consecutive hyphens. Must not be provided when deleting a read replica. | `string` | `null` | no |
| <a name="input_final_snapshot_identifier_prefix"></a> [final\_snapshot\_identifier\_prefix](#input\_final\_snapshot\_identifier\_prefix) | The name which is prefixed to the final snapshot on cluster destroy | `string` | `"final"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS instance | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1' | `number` | `0` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | `"multi region KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name for kms for encrypting the secretsmanager | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | Unique name for the KMS role | `string` | n/a | yes |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description of lambda used for the secret rotation | `string` | `"Lambda function code for secretsmanager rotation"` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of lambda function used for the secret rotation. | `string` | `"secretsmanager_rotation"` | no |
| <a name="input_lambda_handler_name"></a> [lambda\_handler\_name](#input\_lambda\_handler\_name) | Lambda function entrypoint in your code | `string` | `null` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Identifier of the lambda function's runtime | `string` | `"python3.9"` | no |
| <a name="input_layer_version_compatible_architectures"></a> [layer\_version\_compatible\_architectures](#input\_layer\_version\_compatible\_architectures) | List of Architectures this layer is compatible with. Currently x86\_64 and arm64 can be specified | `string` | `null` | no |
| <a name="input_layer_version_compatible_runtimes"></a> [layer\_version\_compatible\_runtimes](#input\_layer\_version\_compatible\_runtimes) | A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified | `list(string)` | <pre>[<br>  "python3.9"<br>]</pre> | no |
| <a name="input_layer_version_layer_name"></a> [layer\_version\_layer\_name](#input\_layer\_version\_layer\_name) | Unique name for your Lambda Layer | `string` | `null` | no |
| <a name="input_layer_version_permission_action"></a> [layer\_version\_permission\_action](#input\_layer\_version\_permission\_action) | Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documentation. | `string` | `null` | no |
| <a name="input_layer_version_permission_principal"></a> [layer\_version\_permission\_principal](#input\_layer\_version\_permission\_principal) | AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely | `string` | `null` | no |
| <a name="input_layer_version_permission_statement_id"></a> [layer\_version\_permission\_statement\_id](#input\_layer\_version\_permission\_statement\_id) | The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for | `string` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | License model information for this DB instance. Optional, but required for some DB engines, i.e. Oracle SE1 | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00 | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided | `bool` | `false` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. | `number` | `0` | no |
| <a name="input_memory_freeable_too_low_threshold"></a> [memory\_freeable\_too\_low\_threshold](#input\_memory\_freeable\_too\_low\_threshold) | Alarm threshold for the lowFreeableMemory alarm | `string` | `"256000000"` | no |
| <a name="input_memory_swap_usage_too_high_threshold"></a> [memory\_swap\_usage\_too\_high\_threshold](#input\_memory\_swap\_usage\_too\_high\_threshold) | Alarm threshold for the highSwapUsage alarm | `string` | `"256000000"` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `1` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_nchar_character_set_name"></a> [nchar\_character\_set\_name](#input\_nchar\_character\_set\_name) | (Optional, Forces new resource) The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS. | `string` | `null` | no |
| <a name="input_option_group_timeouts"></a> [option\_group\_timeouts](#input\_option\_group\_timeouts) | Define maximum timeout for deletion of `aws_db_option_group` resource | `map(string)` | <pre>{<br>  "delete": "35m"<br>}</pre> | no |
| <a name="input_options"></a> [options](#input\_options) | A list of DB options to apply with an option group. Depends on DB engine | <pre>list(object({<br>    db_security_group_memberships  = list(string)<br>    option_name                    = string<br>    port                           = number<br>    version                        = string<br>    vpc_security_group_memberships = list(string)<br><br>    option_settings = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of DB parameters (map) to apply | `list(map(string))` | <pre>[<br>  {<br>    "name": "audit_trail",<br>    "value": "DB"<br>  },<br>  {<br>    "name": "open_cursors",<br>    "value": "5000"<br>  }<br>]</pre> | no |
| <a name="input_password"></a> [password](#input\_password) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights are enabled | `bool` | `true` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections | `string` | `null` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | (Optional) Length of random password to create. (default: 16) | `number` | `16` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `7` | no |
| <a name="input_replica_mode"></a> [replica\_mode](#input\_replica\_mode) | (Optional) Specifies whether the replica is in either mounted or open-read-only mode. This attribute is only supported by Oracle instances. Oracle replicas operate in open-read-only mode unless otherwise specified. See Working with Oracle Read Replicas for more information. | `string` | `null` | no |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate. | `string` | `null` | no |
| <a name="input_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#input\_restore\_to\_point\_in\_time) | Restore to a point in time. This setting does not apply to aurora-mysql or aurora-postgresql. | `map(string)` | `null` | no |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | Specifies if rotation is set or not | `bool` | `false` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket location containing the function's deployment package. Conflicts with filename and image\_uri. This bucket must reside in the same AWS region where you are creating the Lambda function | `string` | `null` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | Required for this example.  Existing S3 bucket name for RDS export/import | `string` | `""` | no |
| <a name="input_s3_import"></a> [s3\_import](#input\_s3\_import) | Restore from a Percona Xtrabackup in S3 (only MySQL is supported) | `map(string)` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of an object containing the function's deployment package. Conflicts with filename and image\_uri. | `string` | `null` | no |
| <a name="input_secretsmanager_name"></a> [secretsmanager\_name](#input\_secretsmanager\_name) | Name of the new secret | `string` | `null` | no |
| <a name="input_secretsmanager_tags"></a> [secretsmanager\_tags](#input\_secretsmanager\_tags) | Key-value map of user-defined tags that are attached to the secret | `map(string)` | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags for the RDS security group | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final\_snapshot\_identifier | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | `string` | `null` | no |
| <a name="input_source_dir"></a> [source\_dir](#input\_source\_dir) | Package entire contents of this directory into the archive. | `string` | `"lambda_source"` | no |
| <a name="input_statistic_period"></a> [statistic\_period](#input\_statistic\_period) | The number of seconds that make each statistic period. | `string` | `"60"` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB instance is encrypted.  Note that if you are creating a cross-region read replica this field is ignored and you should instead declare kms\_key\_id with a valid ARN. The default is false if not specified. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Amount of time your Lambda Function has to run in seconds | `number` | `10` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times | `map(string)` | <pre>{<br>  "create": "60m",<br>  "delete": "60m",<br>  "update": "80m"<br>}</pre> | no |
| <a name="input_user"></a> [user](#input\_user) | User id for aws session | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Username for the master DB user | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomalous_connection_count_metric_alarm_arn"></a> [anomalous\_connection\_count\_metric\_alarm\_arn](#output\_anomalous\_connection\_count\_metric\_alarm\_arn) | The ARN of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_anomalous_connection_count_metric_alarm_id"></a> [anomalous\_connection\_count\_metric\_alarm\_id](#output\_anomalous\_connection\_count\_metric\_alarm\_id) | The ID of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_cpu_utilization_too_high_metric_alarm_arn"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_arn](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_arn) | The ARN of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_cpu_utilization_too_high_metric_alarm_id"></a> [cpu\_utilization\_too\_high\_metric\_alarm\_id](#output\_cpu\_utilization\_too\_high\_metric\_alarm\_id) | The ID of the cpu\_utilization\_too\_high cloudwatch metric alarm |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The address of the RDS instance |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS instance |
| <a name="output_db_instance_availability_zone"></a> [db\_instance\_availability\_zone](#output\_db\_instance\_availability\_zone) | The availability zone of the RDS instance |
| <a name="output_db_instance_ca_cert_identifier"></a> [db\_instance\_ca\_cert\_identifier](#output\_db\_instance\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The connection endpoint |
| <a name="output_db_instance_host"></a> [db\_instance\_host](#output\_db\_instance\_host) | The RDS address |
| <a name="output_db_instance_hosted_zone_id"></a> [db\_instance\_hosted\_zone\_id](#output\_db\_instance\_hosted\_zone\_id) | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The RDS instance ID |
| <a name="output_db_instance_master_password"></a> [db\_instance\_master\_password](#output\_db\_instance\_master\_password) | The master password |
| <a name="output_db_instance_master_user_secret"></a> [db\_instance\_master\_user\_secret](#output\_db\_instance\_master\_user\_secret) | The ARN of the master user secret (Only available when manage\_master\_user\_password is set to true) |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | The database name |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The database port |
| <a name="output_db_instance_resource_id"></a> [db\_instance\_resource\_id](#output\_db\_instance\_resource\_id) | The RDS Resource ID of this instance |
| <a name="output_db_instance_status"></a> [db\_instance\_status](#output\_db\_instance\_status) | The RDS instance status |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | The master username for the database |
| <a name="output_db_option_group_arn"></a> [db\_option\_group\_arn](#output\_db\_option\_group\_arn) | The ARN of the db option group |
| <a name="output_db_option_group_id"></a> [db\_option\_group\_id](#output\_db\_option\_group\_id) | The db option group id |
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
| <a name="output_egress_security_group_rule_id"></a> [egress\_security\_group\_rule\_id](#output\_egress\_security\_group\_rule\_id) | The egress security group rule id. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | Map of IAM Role object |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_iam_role_create_date"></a> [iam\_role\_create\_date](#output\_iam\_role\_create\_date) | The IAM role create date |
| <a name="output_iam_role_description"></a> [iam\_role\_description](#output\_iam\_role\_description) | The description of the role. |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | The stable and unique string identifying the role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role created |
| <a name="output_ingress_security_group_rule_id"></a> [ingress\_security\_group\_rule\_id](#output\_ingress\_security\_group\_rule\_id) | The ingress security group rule id. |
| <a name="output_layer_version_arn"></a> [layer\_version\_arn](#output\_layer\_version\_arn) | ARN of the Lambda Layer with version. |
| <a name="output_layer_version_created_date"></a> [layer\_version\_created\_date](#output\_layer\_version\_created\_date) | Date this resource was created. |
| <a name="output_layer_version_layer_arn"></a> [layer\_version\_layer\_arn](#output\_layer\_version\_layer\_arn) | ARN of the Lambda Layer without version. |
| <a name="output_layer_version_permission_id"></a> [layer\_version\_permission\_id](#output\_layer\_version\_permission\_id) | The layer\_name and version\_number, separated by a comma (,). |
| <a name="output_layer_version_permission_policy"></a> [layer\_version\_permission\_policy](#output\_layer\_version\_permission\_policy) | Full Lambda Layer Permission policy. |
| <a name="output_layer_version_permission_revision_id"></a> [layer\_version\_permission\_revision\_id](#output\_layer\_version\_permission\_revision\_id) | A unique identifier for the current revision of the policy. |
| <a name="output_layer_version_signing_job_arn"></a> [layer\_version\_signing\_job\_arn](#output\_layer\_version\_signing\_job\_arn) | ARN of a signing job. |
| <a name="output_layer_version_signing_profile_version_arn"></a> [layer\_version\_signing\_profile\_version\_arn](#output\_layer\_version\_signing\_profile\_version\_arn) | ARN for a signing profile version. |
| <a name="output_layer_version_source_code_size"></a> [layer\_version\_source\_code\_size](#output\_layer\_version\_source\_code\_size) | Size in bytes of the function .zip file. |
| <a name="output_layer_version_version"></a> [layer\_version\_version](#output\_layer\_version\_version) | Lambda Layer version. |
| <a name="output_managed_ad_access_url"></a> [managed\_ad\_access\_url](#output\_managed\_ad\_access\_url) | The access URL for the directory/connector, such as http://alias.awsapps.com. |
| <a name="output_managed_ad_alias"></a> [managed\_ad\_alias](#output\_managed\_ad\_alias) | The alias for the directory/connector, such as d-991708b282.awsapps.com. |
| <a name="output_managed_ad_description"></a> [managed\_ad\_description](#output\_managed\_ad\_description) | A textual description for the directory/connector. |
| <a name="output_managed_ad_name"></a> [managed\_ad\_name](#output\_managed\_ad\_name) | The fully qualified name for the directory/connector. |
| <a name="output_managed_ad_rds_iam_role_arn"></a> [managed\_ad\_rds\_iam\_role\_arn](#output\_managed\_ad\_rds\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the role. |
| <a name="output_managed_ad_rds_iam_role_description"></a> [managed\_ad\_rds\_iam\_role\_description](#output\_managed\_ad\_rds\_iam\_role\_description) | Description for the role. |
| <a name="output_managed_ad_rds_iam_role_id"></a> [managed\_ad\_rds\_iam\_role\_id](#output\_managed\_ad\_rds\_iam\_role\_id) | The friendly IAM role name to match. |
| <a name="output_managed_ad_short_name"></a> [managed\_ad\_short\_name](#output\_managed\_ad\_short\_name) | The short name of the directory/connector, such as CORP. |
| <a name="output_managed_ad_type"></a> [managed\_ad\_type](#output\_managed\_ad\_type) | The Managed AD directory type. |
| <a name="output_memory_freeable_too_low_metric_alarm_arn"></a> [memory\_freeable\_too\_low\_metric\_alarm\_arn](#output\_memory\_freeable\_too\_low\_metric\_alarm\_arn) | The ARN of the memory\_freeable\_too\_low cloudwatch metric alarm |
| <a name="output_memory_freeable_too_low_metric_alarm_id"></a> [memory\_freeable\_too\_low\_metric\_alarm\_id](#output\_memory\_freeable\_too\_low\_metric\_alarm\_id) | The ID of the memory\_freeable\_too\_low cloudwatch metric alarm |
| <a name="output_memory_swap_usage_too_high_metric_alarm_arn"></a> [memory\_swap\_usage\_too\_high\_metric\_alarm\_arn](#output\_memory\_swap\_usage\_too\_high\_metric\_alarm\_arn) | The ARN of the memory\_swap\_usage\_too\_high cloudwatch metric alarm |
| <a name="output_memory_swap_usage_too_high_metric_alarm_id"></a> [memory\_swap\_usage\_too\_high\_metric\_alarm\_id](#output\_memory\_swap\_usage\_too\_high\_metric\_alarm\_id) | The ID of the memory\_swap\_usage\_too\_high cloudwatch metric alarm |
| <a name="output_rotation_lambda_arn"></a> [rotation\_lambda\_arn](#output\_rotation\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_rotation_lambda_iam_role"></a> [rotation\_lambda\_iam\_role](#output\_rotation\_lambda\_iam\_role) | Map of IAM Role object |
| <a name="output_rotation_lambda_iam_role_arn"></a> [rotation\_lambda\_iam\_role\_arn](#output\_rotation\_lambda\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_rotation_lambda_iam_role_create_date"></a> [rotation\_lambda\_iam\_role\_create\_date](#output\_rotation\_lambda\_iam\_role\_create\_date) | The IAM role create date |
| <a name="output_rotation_lambda_iam_role_description"></a> [rotation\_lambda\_iam\_role\_description](#output\_rotation\_lambda\_iam\_role\_description) | The description of the role. |
| <a name="output_rotation_lambda_iam_role_id"></a> [rotation\_lambda\_iam\_role\_id](#output\_rotation\_lambda\_iam\_role\_id) | The stable and unique string identifying the role |
| <a name="output_rotation_lambda_iam_role_name"></a> [rotation\_lambda\_iam\_role\_name](#output\_rotation\_lambda\_iam\_role\_name) | The name of the IAM role created |
| <a name="output_rotation_lambda_invoke_arn"></a> [rotation\_lambda\_invoke\_arn](#output\_rotation\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |
| <a name="output_rotation_lambda_last_modified"></a> [rotation\_lambda\_last\_modified](#output\_rotation\_lambda\_last\_modified) | Date this resource was last modified |
| <a name="output_rotation_lambda_tags_all"></a> [rotation\_lambda\_tags\_all](#output\_rotation\_lambda\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_secrets_manager_arn"></a> [secrets\_manager\_arn](#output\_secrets\_manager\_arn) | ARN of the secret |
| <a name="output_secrets_manager_replica"></a> [secrets\_manager\_replica](#output\_secrets\_manager\_replica) | Attributes of secrets manager replica are described below |
| <a name="output_secrets_manager_rotation_enabled"></a> [secrets\_manager\_rotation\_enabled](#output\_secrets\_manager\_rotation\_enabled) | Whether automatic rotation is enabled for this secret |
| <a name="output_secrets_manager_version_id"></a> [secrets\_manager\_version\_id](#output\_secrets\_manager\_version\_id) | The unique identifier of the version of the secret |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | security group id |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | security group id |
| <a name="output_security_group_map"></a> [security\_group\_map](#output\_security\_group\_map) | Map of security group object |


<!-- END_TF_DOCS -->