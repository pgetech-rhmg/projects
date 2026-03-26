# db_cluster
output "db_cluster_master_user_secret" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = one(module.aurora-postgresql[*].aurora-postgresql-all[0].aws_rds_cluster_all.master_user_secret[0].secret_arn)

}
output "db_cluster_id" {
  description = "The RDS Cluster Identifier."
  value       = module.aurora-postgresql.db_cluster_id
}
output "db_cluster_arn" {
  description = "The ARN of the db cluster."
  value       = module.aurora-postgresql.db_cluster_arn
}
output "db_cluster_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = module.aurora-postgresql.db_cluster_cluster_identifier
}
output "db_cluster_cluster_resource_id" {
  description = "The RDS Cluster Resource ID."
  value       = module.aurora-postgresql.db_cluster_cluster_resource_id
}
output "db_cluster_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster."
  value       = module.aurora-postgresql.db_cluster_cluster_members
}
output "db_cluster_availability_zones" {
  description = "The availability zone of the instance."
  value       = module.aurora-postgresql.db_cluster_availability_zones
}
output "db_cluster_backup_retention_period" {
  description = "The backup retention period."
  value       = module.aurora-postgresql.db_cluster_backup_retention_period
}
output "db_cluster_preferred_backup_window" {
  description = "The daily time range during which the backups happen."
  value       = module.aurora-postgresql.db_cluster_preferred_backup_window
}
output "db_cluster_preferred_maintenance_window" {
  description = "The maintenance window."
  value       = module.aurora-postgresql.db_cluster_preferred_maintenance_window
}
output "db_cluster_endpoint" {
  description = "The DNS address of the RDS instance."
  value       = module.aurora-postgresql.db_cluster_endpoint
}
output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas."
  value       = module.aurora-postgresql.db_cluster_reader_endpoint
}
output "db_cluster_engine" {
  description = "The database engine."
  value       = module.aurora-postgresql.db_cluster_engine
}
output "db_cluster_engine_version_actual" {
  description = "The running version of the database."
  value       = module.aurora-postgresql.db_cluster_engine_version_actual
}
output "db_cluster_database_name" {
  description = "The database name."
  value       = module.aurora-postgresql.db_cluster_database_name
}
output "db_cluster_port" {
  description = "The database port."
  value       = module.aurora-postgresql.db_cluster_port
}
output "db_cluster_master_username" {
  description = "The master username for the database."
  value       = module.aurora-postgresql.db_cluster_master_username
}
output "db_cluster_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = module.aurora-postgresql.db_cluster_storage_encrypted
}
output "db_cluster_replication_source_identifier" {
  description = "ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica."
  value       = module.aurora-postgresql.db_cluster_replication_source_identifier
}
output "db_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = module.aurora-postgresql.db_cluster_hosted_zone_id
}
output "db_cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block.."
  value       = module.aurora-postgresql.db_cluster_tags_all
}

#db_cluster_instance
output "db_cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of cluster instance."
  value       = module.aurora-postgresql.db_cluster_instance_arn
}
output "db_cluster_instance_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = module.aurora-postgresql.db_cluster_instance_cluster_identifier
}
output "db_cluster_instance_identifier" {
  description = "The Instance identifier."
  value       = module.aurora-postgresql.db_cluster_instance_identifier
}
output "db_cluster_instance_id" {
  description = "The Instance identifier."
  value       = module.aurora-postgresql.db_cluster_instance_id
}
output "db_cluster_instance_writer" {
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
  value       = module.aurora-postgresql.db_cluster_instance_writer
}
output "db_cluster_instance_availability_zone" {
  description = "TThe availability zone of the instance."
  value       = module.aurora-postgresql.db_cluster_instance_availability_zone
}
output "db_cluster_instance_endpoint" {
  description = "The DNS address for this instance. May not be writable."
  value       = module.aurora-postgresql.db_cluster_instance_endpoint
}
output "db_cluster_instance_engine" {
  description = "The database engine."
  value       = module.aurora-postgresql.db_cluster_instance_engine
}
output "db_cluster_instance_engine_version_actual" {
  description = "The database engine version."
  value       = module.aurora-postgresql.db_cluster_instance_engine_version_actual
}
output "db_cluster_instance_port" {
  description = "The database port."
  value       = module.aurora-postgresql.db_cluster_instance_port
}
output "db_cluster_instance_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = module.aurora-postgresql.db_cluster_instance_storage_encrypted
}
output "db_cluster_instance_kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster."
  value       = module.aurora-postgresql.db_cluster_instance_kms_key_id
}
output "db_cluster_instance_dbi_resource_id" {
  description = "The region-unique, immutable identifier for the DB instance."
  value       = module.aurora-postgresql.db_cluster_instance_dbi_resource_id
}
output "db_cluster_instance_performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  value       = module.aurora-postgresql.db_cluster_instance_performance_insights_enabled
}
output "db_cluster_instance_performance_insights_kms_key_id" {
  description = "The ARN for the KMS encryption key used by Performance Insights."
  value       = module.aurora-postgresql.db_cluster_instance_performance_insights_kms_key_id
}
output "db_cluster_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.aurora-postgresql.db_cluster_instance_tags_all
}

# db_cluster_parameter_group
output "db_cluster_parameter_group_id" {
  description = "The db cluster parameter group id."
  value       = module.aurora-postgresql.db_cluster_parameter_group_id
}
output "db_cluster_parameter_group_arn" {
  description = "The ARN of the db cluster parameter group."
  value       = module.aurora-postgresql.db_cluster_parameter_group_arn
}
output "db_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.aurora-postgresql.db_cluster_parameter_group_tags_all
}
output "db_cluster_parameter_group_name" {
  description = "Name of the db cluster parameter group."
  value       = module.aurora-postgresql.db_cluster_parameter_group_name
}

# db_subnet_group
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.aurora-postgresql.db_subnet_group_id
}
output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.aurora-postgresql.db_subnet_group_arn
}

# db_parameter_group
output "db_parameter_group_id" {
  description = "The db parameter group name."
  value       = module.aurora-postgresql.db_parameter_group_id
}
output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = module.aurora-postgresql.db_parameter_group_arn
}

# main_security_group
output "security_group_id" {
  description = "security group id"
  value       = module.aurora-postgresql.security_group_id
}
output "security_group_arn" {
  description = "security group name"
  value       = module.aurora-postgresql.security_group_arn
}


# cloudwatch metric alarms
output "cpu_utilization_too_high_metric_alarm_arn" {
  description = "The ARN of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.cpu_utilization_too_high_metric_alarm_arn
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.cpu_utilization_too_high_metric_alarm_id
}
output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_queue_depth_too_high_metric_alarm_arn
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_queue_depth_too_high_metric_alarm_id
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_free_storage_space_too_low_metric_alarm_arn
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_free_storage_space_too_low_metric_alarm_id
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_burst_balance_too_low_metric_alarm_arn
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.disk_burst_balance_too_low_metric_alarm_id
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.memory_freeable_too_low_metric_alarm_arn
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.aurora-postgresql.memory_freeable_too_low_metric_alarm_id
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.memory_swap_usage_too_high_metric_alarm_arn
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.aurora-postgresql.memory_swap_usage_too_high_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.aurora-postgresql.anomalous_connection_count_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.aurora-postgresql.anomalous_connection_count_metric_alarm_arn
}

#SSM Params Replica
output "ssm_param_db_instance_replica_arn" {
  description = "The ARN of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.replica.arn
}
output "ssm_param_db_instance_replica_name" {
  description = "The name of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.replica.name
}
output "ssm_param_db_instance_replica_type" {
  description = "The type of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.replica.type
}
output "ssm_param_db_instance_replica_value" {
  description = "The value of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.replica.value
  sensitive   = true
}
output "ssm_param_db_instance_replica_version" {
  description = "The version of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.replica.version
}

#SSM Params Primary
output "ssm_param_db_instance_primary_arn" {
  description = "The ARN of the parameter storing the cluster db instance primary."
  value       = aws_ssm_parameter.primary.arn
}
output "ssm_param_db_instance_primary_name" {
  description = "The name of the parameter storing the cluster db instance primary."
  value       = aws_ssm_parameter.primary.name
}
output "ssm_param_db_instance_primary_type" {
  description = "The type of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.primary.type
}
output "ssm_param_db_instance_primary_value" {
  description = "The value of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.primary.value
  sensitive   = true
}
output "ssm_param_db_instance_primary_version" {
  description = "The version of the parameter storing the cluster db instance replica."
  value       = aws_ssm_parameter.primary.version
}

#SSM Params DB Cluster Arn
output "ssm_param_db_cluster_arn_arn" {
  description = "The ARN of the parameter storing the cluster db cluster arn."
  value       = aws_ssm_parameter.cluster_arn.arn
}
output "ssm_param_db_cluster_arn_name" {
  description = "The name of the parameter storing the cluster db cluster arn."
  value       = aws_ssm_parameter.cluster_arn.name
}
output "ssm_param_db_cluster_arn_type" {
  description = "The type of the parameter storing the cluster db cluster arn."
  value       = aws_ssm_parameter.cluster_arn.type
}
output "ssm_param_db_cluster_arn_value" {
  description = "The value of the parameter storing the cluster db cluster arn."
  value       = aws_ssm_parameter.cluster_arn.value
  sensitive   = true
}
output "ssm_param_db_cluster_arn_version" {
  description = "The version of the parameter storing the cluster db cluster arn."
  value       = aws_ssm_parameter.cluster_arn.version
}

#SSM Params DB Cluster Subnet Group
output "ssm_param_db_cluster_subnet_group_arn" {
  description = "The ARN of the parameter storing the cluster db cluster subnet group."
  value       = aws_ssm_parameter.cluster_subnet_group.arn
}
output "ssm_param_db_cluster_subnet_group_name" {
  description = "The name of the parameter storing the cluster db cluster subnet group."
  value       = aws_ssm_parameter.cluster_subnet_group.name
}
output "ssm_param_db_cluster_subnet_group_type" {
  description = "The type of the parameter storing the cluster db cluster subnet group."
  value       = aws_ssm_parameter.cluster_subnet_group.type
}
output "ssm_param_db_cluster_subnet_group_value" {
  description = "The value of the parameter storing the cluster db cluster subnet group."
  value       = aws_ssm_parameter.cluster_subnet_group.value
  sensitive   = true
}
output "ssm_param_db_cluster_subnet_group_version" {
  description = "The version of the parameter storing the cluster db cluster subnet group."
  value       = aws_ssm_parameter.cluster_subnet_group.version
}

#SSM Params DB Cluster Security Group
output "ssm_param_db_cluster_security_group_arn" {
  description = "The ARN of the parameter storing the cluster db cluster security group."
  value       = aws_ssm_parameter.cluster_subnet_group.arn
}
output "ssm_param_db_cluster_security_group_name" {
  description = "The name of the parameter storing the cluster db cluster security group."
  value       = aws_ssm_parameter.cluster_subnet_group.name
}
output "ssm_param_db_cluster_security_group_type" {
  description = "The type of the parameter storing the cluster db cluster security group."
  value       = aws_ssm_parameter.cluster_subnet_group.type
}
output "ssm_param_db_cluster_security_group_value" {
  description = "The value of the parameter storing the cluster db cluster security group."
  value       = aws_ssm_parameter.cluster_subnet_group.value
  sensitive   = true
}
output "ssm_param_db_cluster_security_group_version" {
  description = "The version of the parameter storing the cluster db cluster security group."
  value       = aws_ssm_parameter.cluster_subnet_group.version
}

#SSM Params DB Cluster Param Group
output "ssm_param_db_cluster_param_group_arn" {
  description = "The ARN of the parameter storing the cluster db cluster param group."
  value       = aws_ssm_parameter.cluster_param_group.arn
}
output "ssm_param_db_cluster_param_group_name" {
  description = "The name of the parameter storing the cluster db cluster param group."
  value       = aws_ssm_parameter.cluster_param_group.name
}
output "ssm_param_db_cluster_param_group_type" {
  description = "The type of the parameter storing the cluster db cluster param group."
  value       = aws_ssm_parameter.cluster_param_group.type
}
output "ssm_param_db_cluster_param_group_value" {
  description = "The value of the parameter storing the cluster db cluster param group."
  value       = aws_ssm_parameter.cluster_param_group.value
  sensitive   = true
}
output "ssm_param_db_cluster_param_group_version" {
  description = "The version of the parameter storing the cluster db cluster param group."
  value       = aws_ssm_parameter.cluster_param_group.version
}

#SSM Params DB Cluster Instance Param Group
output "ssm_param_db_cluster_instance_param_group_arn" {
  description = "The ARN of the parameter storing the cluster db cluster instance param group."
  value       = aws_ssm_parameter.instance_param_group.arn
}
output "ssm_param_db_cluster_instance_param_group_name" {
  description = "The name of the parameter storing the cluster db cluster instance param group."
  value       = aws_ssm_parameter.instance_param_group.name
}
output "ssm_param_db_cluster_instance_param_group_type" {
  description = "The type of the parameter storing the cluster db cluster instance param group."
  value       = aws_ssm_parameter.instance_param_group.type
}
output "ssm_param_db_cluster_instance_param_group_value" {
  description = "The value of the parameter storing the cluster db cluster instance param group."
  value       = aws_ssm_parameter.instance_param_group.value
  sensitive   = true
}
output "ssm_param_db_cluster_instance_param_group_version" {
  description = "The version of the parameter storing the cluster db cluster instance param group."
  value       = aws_ssm_parameter.instance_param_group.version
}

#SSM Params DB Cluster Password
# Storage of db password
output "ssm_param_db_generated_master_password_arn" {
  description = "The ARN of the parameter storing the generated db master password."
  value       = module.aurora-postgresql.ssm_param_db_generated_master_password_arn
}
output "ssm_param_ddb_generated_master_password_name" {
  description = "The name of the parameter storing the generated db master password."
  value       = module.aurora-postgresql.ssm_param_ddb_generated_master_password_name
}
output "ssm_param_db_generated_master_password_type" {
  description = "The type of the parameter storing the generated db master password."
  value       = module.aurora-postgresql.ssm_param_db_generated_master_password_type
}
output "ssm_param_db_generated_master_password_value" {
  description = "The value of the parameter storing the generated db master password."
  value       = module.aurora-postgresql.ssm_param_db_generated_master_password_value
  sensitive   = true
}
output "ssm_param_db_generated_master_password_version" {
  description = "The version of the parameter storing the generated db master password."
  value       = module.aurora-postgresql.ssm_param_db_generated_master_password_value
  sensitive   = true
}

# RDS Proxy
output "proxy_id" {
  description = "The ID for the proxy"
  value       = module.rds_proxy.proxy_id
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = module.rds_proxy.proxy_arn
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = module.rds_proxy.proxy_endpoint
}

# Proxy Default Target Group
output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = module.rds_proxy.proxy_default_target_group_id
}

output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = module.rds_proxy.proxy_default_target_group_arn
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = module.rds_proxy.proxy_default_target_group_name
}

# Proxy Target
output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = module.rds_proxy.proxy_target_endpoint
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = module.rds_proxy.proxy_target_id
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = module.rds_proxy.proxy_target_port
}

output "proxy_target_rds_resource_id" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = module.rds_proxy.proxy_target_rds_resource_id
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = module.rds_proxy.proxy_target_target_arn
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = module.rds_proxy.proxy_target_tracked_cluster_id
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = module.rds_proxy.proxy_target_type
}

# DB proxy endpoints
output "db_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = module.rds_proxy.db_proxy_endpoints
  sensitive   = true
}

# CloudWatch logs
output "log_group_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch log group"
  value       = module.rds_proxy.log_group_arn
}

# IAM role
# output "iam_role_arn" {
#   description = "The Amazon Resource Name (ARN) specifying the role proxy uses to access secrets"
#   value       = module.rds_proxy[*].iam_role_arn
# }

# output "iam_role_name" {
#   description = "The name of the role proxy uses to access secrets"
#   value       = module.rds_proxy[*].iam_role_name
# }

# output "iam_role_unique_id" {
#   description = "Stable and unique string identifying the role proxy uses to access secrets"
#   value       = module.rds_proxy[*].iam_role_unique_id
# }