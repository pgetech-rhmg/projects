#db_cluster_instance
output "db_cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of cluster instance."
  value       = module.db_cluster_instance.db_cluster_instance_arn
}
output "db_cluster_instance_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = module.db_cluster_instance.db_cluster_instance_cluster_identifier
}
output "db_cluster_instance_identifier" {
  description = "The Instance identifier."
  value       = module.db_cluster_instance.db_cluster_instance_identifier
}
output "db_cluster_instance_id" {
  description = "The Instance identifier."
  value       = module.db_cluster_instance.db_cluster_instance_id
}
output "db_cluster_instance_writer" {
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
  value       = module.db_cluster_instance.db_cluster_instance_writer
}
output "db_cluster_instance_availability_zone" {
  description = "TThe availability zone of the instance."
  value       = module.db_cluster_instance.db_cluster_instance_availability_zone
}
output "db_cluster_instance_endpoint" {
  description = "The DNS address for this instance. May not be writable."
  value       = module.db_cluster_instance.db_cluster_instance_endpoint
}
output "db_cluster_instance_engine" {
  description = "The database engine."
  value       = module.db_cluster_instance.db_cluster_instance_engine
}
output "db_cluster_instance_engine_version_actual" {
  description = "The database engine version."
  value       = module.db_cluster_instance.db_cluster_instance_engine_version_actual
}
output "db_cluster_instance_port" {
  description = "The database port."
  value       = module.db_cluster_instance.db_cluster_instance_port
}
output "db_cluster_instance_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = module.db_cluster_instance.db_cluster_instance_storage_encrypted
}
output "db_cluster_instance_kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster."
  value       = module.db_cluster_instance.db_cluster_instance_kms_key_id
}
output "db_cluster_instance_dbi_resource_id" {
  description = "The region-unique, immutable identifier for the DB instance."
  value       = module.db_cluster_instance.db_cluster_instance_dbi_resource_id
}
output "db_cluster_instance_performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  value       = module.db_cluster_instance.db_cluster_instance_performance_insights_enabled
}
output "db_cluster_instance_performance_insights_kms_key_id" {
  description = "The ARN for the KMS encryption key used by Performance Insights."
  value       = module.db_cluster_instance.db_cluster_instance_performance_insights_kms_key_id
}
output "db_cluster_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.db_cluster_instance[*].db_cluster_instance_tags_all
}


# db_cluster
output "db_cluster_id" {
  description = "The RDS Cluster Identifier."
  value       = element(concat(module.db_cluster[*].db_cluster_id, [""]), 0)
}
output "db_cluster_arn" {
  description = "The ARN of the db cluster."
  value       = element(concat(module.db_cluster[*].db_cluster_arn, [""]), 0)
}
output "db_cluster_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = element(concat(module.db_cluster[*].db_cluster_cluster_identifier, [""]), 0)
}
output "db_cluster_cluster_resource_id" {
  description = "The RDS Cluster Resource ID."
  value       = element(concat(module.db_cluster[*].db_cluster_cluster_resource_id, [""]), 0)
}
output "db_cluster_cluster_members" {
  description = "List of RDS Instances that are a part of this cluster."
  value       = element(concat(module.db_cluster[*].db_cluster_cluster_members, [""]), 0)
}
output "db_cluster_availability_zones" {
  description = "The availability zone of the instance."
  value       = element(concat(module.db_cluster[*].db_cluster_availability_zones, [""]), 0)
}
output "db_cluster_backup_retention_period" {
  description = "The backup retention period."
  value       = element(concat(module.db_cluster[*].db_cluster_backup_retention_period, [""]), 0)
}
output "db_cluster_preferred_backup_window" {
  description = "The daily time range during which the backups happen."
  value       = element(concat(module.db_cluster[*].db_cluster_preferred_backup_window, [""]), 0)
}
output "db_cluster_preferred_maintenance_window" {
  description = "The maintenance window."
  value       = element(concat(module.db_cluster[*].db_cluster_preferred_maintenance_window, [""]), 0)
}
output "db_cluster_endpoint" {
  description = "The DNS address of the RDS instance."
  value       = element(concat(module.db_cluster[*].db_cluster_endpoint, [""]), 0)
}
output "db_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas."
  value       = element(concat(module.db_cluster[*].db_cluster_reader_endpoint, [""]), 0)
}
output "db_cluster_engine" {
  description = "The database engine."
  value       = element(concat(module.db_cluster[*].db_cluster_engine, [""]), 0)
}
output "db_cluster_engine_version_actual" {
  description = "The running version of the database."
  value       = element(concat(module.db_cluster[*].db_cluster_engine_version_actual, [""]), 0)
}
output "db_cluster_database_name" {
  description = "The database name."
  value       = element(concat(module.db_cluster[*].db_cluster_database_name, [""]), 0)
}
output "db_cluster_port" {
  description = "The database port."
  value       = element(concat(module.db_cluster[*].db_cluster_port, [""]), 0)
}
output "db_cluster_master_username" {
  description = "The master username for the database."
  value       = element(concat(module.db_cluster[*].db_cluster_master_username, [""]), 0)
}
output "db_cluster_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = element(concat(module.db_cluster[*].db_cluster_storage_encrypted, [""]), 0)
}
output "db_cluster_replication_source_identifier" {
  description = "ARN of the source DB cluster or DB instance if this DB cluster is created as a Read Replica."
  value       = element(concat(module.db_cluster[*].db_cluster_replication_source_identifier, [""]), 0)
}
output "db_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = element(concat(module.db_cluster[*].db_cluster_hosted_zone_id, [""]), 0)
}
output "db_cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block.."
  value       = element(concat(module.db_cluster[*].db_cluster_tags_all, [""]), 0)
}

# db_cluster_parameter_group
output "db_cluster_parameter_group_id" {
  description = "The db cluster parameter group id."
  value       = module.db_cluster_parameter_group.db_cluster_parameter_group_id
}
output "db_cluster_parameter_group_arn" {
  description = "The ARN of the db cluster parameter group."
  value       = module.db_cluster_parameter_group.db_cluster_parameter_group_arn
}
output "db_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.db_cluster_parameter_group.db_cluster_parameter_group_tags_all
}
output "db_cluster_parameter_group_name" {
  description = "Name of the db cluster parameter group."
  value       = module.db_cluster_parameter_group.db_cluster_parameter_group_name
}

# db_subnet_group
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.db_subnet_group.db_subnet_group_id
}
output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.db_subnet_group.db_subnet_group_arn
}

# db_parameter_group
output "db_parameter_group_id" {
  description = "The db parameter group name."
  value       = module.db_parameter_group.db_parameter_group_id
}
output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = module.db_parameter_group.db_parameter_group_arn
}

# main_security_group
output "security_group_id" {
  description = "security group id"
  value       = module.main_security_group.sg_id
}
output "security_group_arn" {
  description = "security group name"
  value       = module.main_security_group.sg_arn
}


# cloudwatch metric alarms
output "cpu_utilization_too_high_metric_alarm_arn" {
  description = "The ARN of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.cpu_utilization_too_high_metric_alarm_arn
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.cpu_utilization_too_high_metric_alarm_id
}
output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_queue_depth_too_high_metric_alarm_arn
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_queue_depth_too_high_metric_alarm_id
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_free_storage_space_too_low_metric_alarm_arn
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_free_storage_space_too_low_metric_alarm_id
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_burst_balance_too_low_metric_alarm_arn
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.disk_burst_balance_too_low_metric_alarm_id
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.memory_freeable_too_low_metric_alarm_arn
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.db_cluster_instance.memory_freeable_too_low_metric_alarm_id
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.memory_swap_usage_too_high_metric_alarm_arn
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.db_cluster_instance.memory_swap_usage_too_high_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.db_cluster_instance.anomalous_connection_count_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.db_cluster_instance.anomalous_connection_count_metric_alarm_arn
}

#SSM Params DB Cluster Password
output "ssm_param_db_generated_master_password_arn" {
  description = "The ARN of the parameter storing the generated db master password."
  value       = one(module.ssm_parameter[*].arn)
}
output "ssm_param_ddb_generated_master_password_name" {
  description = "The name of the parameter storing the generated db master password."
  value       = one(module.ssm_parameter[*].name)
}
output "ssm_param_db_generated_master_password_type" {
  description = "The type of the parameter storing the generated db master password."
  value       = one(module.ssm_parameter[*].type)
}
output "ssm_param_db_generated_master_password_value" {
  description = "The value of the parameter storing the generated db master password."
  value       = one(module.ssm_parameter[*].value)
  sensitive   = true
}
output "ssm_param_db_generated_master_password_version" {
  description = "The version of the parameter storing the generated db master password."
  value       = one(module.ssm_parameter[*].version)
}

output "aurora-postgresql-all" {
  description = "A list of map of all the outputs from the module"
  value       = [module.db_cluster, module.db_cluster_instance, module.db_cluster_parameter_group, module.db_subnet_group, module.db_parameter_group, module.main_security_group, module.ssm_parameter[*]]
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = module.db_cluster.cluster_master_user_secret

}