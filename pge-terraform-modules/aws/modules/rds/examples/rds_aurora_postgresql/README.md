<!-- BEGIN_TF_DOCS -->
# RDS Aurora Postgresql module
Terraform module which creates an RDS Aurora Postgresql Database.
Pre-Requisites:
   1. IAM Role rds-enhanced-monitoring-role exists within your account (should be automatically deployed to PG&E accounts)
   2. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds\_vpc\_endpoint example module (rds/examples/rds\_vpc\_endpoint)
Notes:
  1. At this time, the secrets manager is not implemented to store the master credentials.  User will need to do so manually
     and ensure that the secret is rotated before 90 days.  All other Saf Compliance is implemented.
  2. This module will also create various SSM Parameters to store data pertaining to the DB Cluster and it's instances.
  3. This module includes logic to pass in private subnets and vpc(/vpc/privatesubnet1/id, /vpc/privatesubnet2/id,
     /vpc/privatesubnet3/id, /vpc/id).  Be sure that the account in which you are using has adequate IP space for the subnets stored in Parameter Store.
  4. Serverless v1 clusters do not support managed master user password, Aurora Serverless v2 is supported for MySQL 8.0 onwards & PostgreSQL 13 onwards.
  5. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process

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
| <a name="module_aurora-postgresql"></a> [aurora-postgresql](#module\_aurora-postgresql) | ../../modules/aurora-postgresql | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.cluster_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.cluster_param_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.cluster_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.cluster_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.instance_param_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
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
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | (Optional) The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster). | `string` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | (Optional) Enable to allow major engine version upgrades when changing engine versions. Defaults to false. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information. | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | Unique name for the role | `string` | n/a | yes |
| <a name="input_cluster_instance_count"></a> [cluster\_instance\_count](#input\_cluster\_instance\_count) | Number of instances to create. | `number` | `1` | no |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | A list of DB cluster parameter maps to apply.  Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-cluster-parameters after initial creation of the group. | `list(map(string))` | `[]` | no |
| <a name="input_cluster_performance_insights_enabled"></a> [cluster\_performance\_insights\_enabled](#input\_cluster\_performance\_insights\_enabled) | (Optional) Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_cluster_performance_insights_kms_key_id"></a> [cluster\_performance\_insights\_kms\_key\_id](#input\_cluster\_performance\_insights\_kms\_key\_id) | (Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `null` | no |
| <a name="input_cluster_performance_insights_retention_period"></a> [cluster\_performance\_insights\_retention\_period](#input\_cluster\_performance\_insights\_retention\_period) | (Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance\_insights\_retention\_period, performance\_insights\_enabled needs to be set to true. Defaults to '7'. | `number` | `7` | no |
| <a name="input_cpu_credit_balance_too_low_threshold"></a> [cpu\_credit\_balance\_too\_low\_threshold](#input\_cpu\_credit\_balance\_too\_low\_threshold) | Alarm threshold for the 'lowCPUCreditBalance' alarm | `string` | `"100"` | no |
| <a name="input_custom_instance_names"></a> [custom\_instance\_names](#input\_custom\_instance\_names) | (Optional) List of custom names for cluster instances. If provided, the list length must match cluster\_instance\_count. If not provided, defaults to identifier-0, identifier-1, etc. for backward compatibility. Example: ['mydb-writer', 'mydb-reader-1', 'mydb-reader-2'] | `list(string)` | `[]` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Optional) Name for an automatically created database on cluster creation. Must be lowercase, begin with a letter, and alphanumeric(There are different naming restrictions per database engine: RDS Naming Constraints). | `string` | `null` | no |
| <a name="input_db_cluster_instance_tags"></a> [db\_cluster\_instance\_tags](#input\_db\_cluster\_instance\_tags) | Additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_cluster_parameter_group_tags"></a> [db\_cluster\_parameter\_group\_tags](#input\_db\_cluster\_parameter\_group\_tags) | Additional tags for the  DB cluster parameter group | `map(string)` | `{}` | no |
| <a name="input_db_parameter_group_tags"></a> [db\_parameter\_group\_tags](#input\_db\_parameter\_group\_tags) | Additional tags for the  DB parameter group | `map(string)` | `{}` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | Additional tags for the DB subnet group | `map(string)` | `{}` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | `bool` | `false` | no |
| <a name="input_enable_http_endpoint"></a> [enable\_http\_endpoint](#input\_enable\_http\_endpoint) | (Optional) Enable HTTP endpoint (data API). Only valid when engine\_mode is set to serverless. | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL). | `list(string)` | <pre>[<br>  "postgresql"<br>]</pre> | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | (Optional) The database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), multimaster, parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless. | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value. For example with Aurora MySQL 2, a potential value for this argument is 5.7.mysql\_aurora.2.03.2. The value can contain a partial version where supported by the API. The actual engine version used is returned in the attribute engine\_version\_actual, , see Attributes Reference below. | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | The family of the DB parameter group | `string` | `""` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | (Optional) The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made. | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Required) The identifier for the RDS aurora cluster resources. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Required) The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details.? | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | (Optional) The amount of provisioned IOPS. Setting this implies a storage\_type of io1. | `number` | `null` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | `"KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name for kms for encrypting the secretsmanager | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS role for the encryption | `string` | n/a | yes |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided | `bool` | `false` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | (Required unless a snapshot\_identifier or replication\_source\_identifier is provided or unless a global\_cluster\_identifier is provided when the cluster is the 'secondary' cluster of a global database) Username for the master DB user. Please refer to the RDS Naming Constraints. This argument does not support in-place updates and cannot be changed during a restore from snapshot. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of DB parameters (map) to apply | `list(map(string))` | <pre>[<br>  {<br>    "name": "log_connections",<br>    "value": "1"<br>  },<br>  {<br>    "name": "log_disconnections",<br>    "value": "1"<br>  },<br>  {<br>    "name": "log_min_duration_statement",<br>    "value": "0"<br>  },<br>  {<br>    "name": "log_statement",<br>    "value": "all"<br>  },<br>  {<br>    "name": "pgaudit.log",<br>    "value": "all"<br>  }<br>]</pre> | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | (Optional) Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | (Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | (Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance\_insights\_retention\_period, performance\_insights\_enabled needs to be set to true. Defaults to '7'. | `number` | `7` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00 | `string` | `null` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | (Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30 | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags for the RDS security group | `map(string)` | `{}` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | (Optional) Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned` | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final\_snapshot\_identifier. Default is false. | `bool` | `false` | no |
| <a name="input_ssm_description"></a> [ssm\_description](#input\_ssm\_description) | Description of the parameter | `string` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | (Optional) Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: io1, Default: io1. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomalous_connection_count_metric_alarm_arn"></a> [anomalous\_connection\_count\_metric\_alarm\_arn](#output\_anomalous\_connection\_count\_metric\_alarm\_arn) | The ARN of the anomalous\_connection\_count cloudwatch metric alarm |
| <a name="output_anomalous_connection_count_metric_alarm_id"></a> [anomalous\_connection\_count\_metric\_alarm\_id](#output\_anomalous\_connection\_count\_metric\_alarm\_id) | The ID of the anomalous\_connection\_count cloudwatch metric alarm |
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
| <a name="output_db_cluster_master_user_secret"></a> [db\_cluster\_master\_user\_secret](#output\_db\_cluster\_master\_user\_secret) | The ARN of the master user secret (Only available when manage\_master\_user\_password is set to true) |
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
| <a name="output_ssm_param_db_cluster_arn_arn"></a> [ssm\_param\_db\_cluster\_arn\_arn](#output\_ssm\_param\_db\_cluster\_arn\_arn) | The ARN of the parameter storing the cluster db cluster arn. |
| <a name="output_ssm_param_db_cluster_arn_name"></a> [ssm\_param\_db\_cluster\_arn\_name](#output\_ssm\_param\_db\_cluster\_arn\_name) | The name of the parameter storing the cluster db cluster arn. |
| <a name="output_ssm_param_db_cluster_arn_type"></a> [ssm\_param\_db\_cluster\_arn\_type](#output\_ssm\_param\_db\_cluster\_arn\_type) | The type of the parameter storing the cluster db cluster arn. |
| <a name="output_ssm_param_db_cluster_arn_value"></a> [ssm\_param\_db\_cluster\_arn\_value](#output\_ssm\_param\_db\_cluster\_arn\_value) | The value of the parameter storing the cluster db cluster arn. |
| <a name="output_ssm_param_db_cluster_arn_version"></a> [ssm\_param\_db\_cluster\_arn\_version](#output\_ssm\_param\_db\_cluster\_arn\_version) | The version of the parameter storing the cluster db cluster arn. |
| <a name="output_ssm_param_db_cluster_instance_param_group_arn"></a> [ssm\_param\_db\_cluster\_instance\_param\_group\_arn](#output\_ssm\_param\_db\_cluster\_instance\_param\_group\_arn) | The ARN of the parameter storing the cluster db cluster instance param group. |
| <a name="output_ssm_param_db_cluster_instance_param_group_name"></a> [ssm\_param\_db\_cluster\_instance\_param\_group\_name](#output\_ssm\_param\_db\_cluster\_instance\_param\_group\_name) | The name of the parameter storing the cluster db cluster instance param group. |
| <a name="output_ssm_param_db_cluster_instance_param_group_type"></a> [ssm\_param\_db\_cluster\_instance\_param\_group\_type](#output\_ssm\_param\_db\_cluster\_instance\_param\_group\_type) | The type of the parameter storing the cluster db cluster instance param group. |
| <a name="output_ssm_param_db_cluster_instance_param_group_value"></a> [ssm\_param\_db\_cluster\_instance\_param\_group\_value](#output\_ssm\_param\_db\_cluster\_instance\_param\_group\_value) | The value of the parameter storing the cluster db cluster instance param group. |
| <a name="output_ssm_param_db_cluster_instance_param_group_version"></a> [ssm\_param\_db\_cluster\_instance\_param\_group\_version](#output\_ssm\_param\_db\_cluster\_instance\_param\_group\_version) | The version of the parameter storing the cluster db cluster instance param group. |
| <a name="output_ssm_param_db_cluster_param_group_arn"></a> [ssm\_param\_db\_cluster\_param\_group\_arn](#output\_ssm\_param\_db\_cluster\_param\_group\_arn) | The ARN of the parameter storing the cluster db cluster param group. |
| <a name="output_ssm_param_db_cluster_param_group_name"></a> [ssm\_param\_db\_cluster\_param\_group\_name](#output\_ssm\_param\_db\_cluster\_param\_group\_name) | The name of the parameter storing the cluster db cluster param group. |
| <a name="output_ssm_param_db_cluster_param_group_type"></a> [ssm\_param\_db\_cluster\_param\_group\_type](#output\_ssm\_param\_db\_cluster\_param\_group\_type) | The type of the parameter storing the cluster db cluster param group. |
| <a name="output_ssm_param_db_cluster_param_group_value"></a> [ssm\_param\_db\_cluster\_param\_group\_value](#output\_ssm\_param\_db\_cluster\_param\_group\_value) | The value of the parameter storing the cluster db cluster param group. |
| <a name="output_ssm_param_db_cluster_param_group_version"></a> [ssm\_param\_db\_cluster\_param\_group\_version](#output\_ssm\_param\_db\_cluster\_param\_group\_version) | The version of the parameter storing the cluster db cluster param group. |
| <a name="output_ssm_param_db_cluster_security_group_arn"></a> [ssm\_param\_db\_cluster\_security\_group\_arn](#output\_ssm\_param\_db\_cluster\_security\_group\_arn) | The ARN of the parameter storing the cluster db cluster security group. |
| <a name="output_ssm_param_db_cluster_security_group_name"></a> [ssm\_param\_db\_cluster\_security\_group\_name](#output\_ssm\_param\_db\_cluster\_security\_group\_name) | The name of the parameter storing the cluster db cluster security group. |
| <a name="output_ssm_param_db_cluster_security_group_type"></a> [ssm\_param\_db\_cluster\_security\_group\_type](#output\_ssm\_param\_db\_cluster\_security\_group\_type) | The type of the parameter storing the cluster db cluster security group. |
| <a name="output_ssm_param_db_cluster_security_group_value"></a> [ssm\_param\_db\_cluster\_security\_group\_value](#output\_ssm\_param\_db\_cluster\_security\_group\_value) | The value of the parameter storing the cluster db cluster security group. |
| <a name="output_ssm_param_db_cluster_security_group_version"></a> [ssm\_param\_db\_cluster\_security\_group\_version](#output\_ssm\_param\_db\_cluster\_security\_group\_version) | The version of the parameter storing the cluster db cluster security group. |
| <a name="output_ssm_param_db_cluster_subnet_group_arn"></a> [ssm\_param\_db\_cluster\_subnet\_group\_arn](#output\_ssm\_param\_db\_cluster\_subnet\_group\_arn) | The ARN of the parameter storing the cluster db cluster subnet group. |
| <a name="output_ssm_param_db_cluster_subnet_group_name"></a> [ssm\_param\_db\_cluster\_subnet\_group\_name](#output\_ssm\_param\_db\_cluster\_subnet\_group\_name) | The name of the parameter storing the cluster db cluster subnet group. |
| <a name="output_ssm_param_db_cluster_subnet_group_type"></a> [ssm\_param\_db\_cluster\_subnet\_group\_type](#output\_ssm\_param\_db\_cluster\_subnet\_group\_type) | The type of the parameter storing the cluster db cluster subnet group. |
| <a name="output_ssm_param_db_cluster_subnet_group_value"></a> [ssm\_param\_db\_cluster\_subnet\_group\_value](#output\_ssm\_param\_db\_cluster\_subnet\_group\_value) | The value of the parameter storing the cluster db cluster subnet group. |
| <a name="output_ssm_param_db_cluster_subnet_group_version"></a> [ssm\_param\_db\_cluster\_subnet\_group\_version](#output\_ssm\_param\_db\_cluster\_subnet\_group\_version) | The version of the parameter storing the cluster db cluster subnet group. |
| <a name="output_ssm_param_db_generated_master_password_arn"></a> [ssm\_param\_db\_generated\_master\_password\_arn](#output\_ssm\_param\_db\_generated\_master\_password\_arn) | The ARN of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_type"></a> [ssm\_param\_db\_generated\_master\_password\_type](#output\_ssm\_param\_db\_generated\_master\_password\_type) | The type of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_value"></a> [ssm\_param\_db\_generated\_master\_password\_value](#output\_ssm\_param\_db\_generated\_master\_password\_value) | The value of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_generated_master_password_version"></a> [ssm\_param\_db\_generated\_master\_password\_version](#output\_ssm\_param\_db\_generated\_master\_password\_version) | The version of the parameter storing the generated db master password. |
| <a name="output_ssm_param_db_instance_primary_arn"></a> [ssm\_param\_db\_instance\_primary\_arn](#output\_ssm\_param\_db\_instance\_primary\_arn) | The ARN of the parameter storing the cluster db instance primary. |
| <a name="output_ssm_param_db_instance_primary_name"></a> [ssm\_param\_db\_instance\_primary\_name](#output\_ssm\_param\_db\_instance\_primary\_name) | The name of the parameter storing the cluster db instance primary. |
| <a name="output_ssm_param_db_instance_primary_type"></a> [ssm\_param\_db\_instance\_primary\_type](#output\_ssm\_param\_db\_instance\_primary\_type) | The type of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_primary_value"></a> [ssm\_param\_db\_instance\_primary\_value](#output\_ssm\_param\_db\_instance\_primary\_value) | The value of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_primary_version"></a> [ssm\_param\_db\_instance\_primary\_version](#output\_ssm\_param\_db\_instance\_primary\_version) | The version of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_replica_arn"></a> [ssm\_param\_db\_instance\_replica\_arn](#output\_ssm\_param\_db\_instance\_replica\_arn) | The ARN of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_replica_name"></a> [ssm\_param\_db\_instance\_replica\_name](#output\_ssm\_param\_db\_instance\_replica\_name) | The name of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_replica_type"></a> [ssm\_param\_db\_instance\_replica\_type](#output\_ssm\_param\_db\_instance\_replica\_type) | The type of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_replica_value"></a> [ssm\_param\_db\_instance\_replica\_value](#output\_ssm\_param\_db\_instance\_replica\_value) | The value of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_db_instance_replica_version"></a> [ssm\_param\_db\_instance\_replica\_version](#output\_ssm\_param\_db\_instance\_replica\_version) | The version of the parameter storing the cluster db instance replica. |
| <a name="output_ssm_param_ddb_generated_master_password_name"></a> [ssm\_param\_ddb\_generated\_master\_password\_name](#output\_ssm\_param\_ddb\_generated\_master\_password\_name) | The name of the parameter storing the generated db master password. |


<!-- END_TF_DOCS -->