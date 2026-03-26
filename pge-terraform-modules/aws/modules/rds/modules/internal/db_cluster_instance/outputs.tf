output "db_cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of cluster instance."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].arn)
}

output "db_cluster_instance_cluster_identifier" {
  description = "The RDS Cluster Identifier."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].cluster_identifier)
}

output "db_cluster_instance_identifier" {
  description = "The Instance identifier."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].identifier)
}

output "db_cluster_instance_id" {
  description = "The Instance identifier."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].id)
}

output "db_cluster_instance_writer" {
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].writer)
}

output "db_cluster_instance_availability_zone" {
  description = "TThe availability zone of the instance."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].availability_zone)
}

output "db_cluster_instance_endpoint" {
  description = "The DNS address for this instance. May not be writable."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].endpoint)
}

output "db_cluster_instance_engine" {
  description = "The database engine."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].engine)
}

output "db_cluster_instance_engine_version_actual" {
  description = "The database engine version."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].engine_version)
}

output "db_cluster_instance_port" {
  description = "The database port."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].port)
}

output "db_cluster_instance_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].storage_encrypted)
}

output "db_cluster_instance_kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].kms_key_id)
}

output "db_cluster_instance_dbi_resource_id" {
  description = "The region-unique, immutable identifier for the DB instance."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].dbi_resource_id)
}

output "db_cluster_instance_performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].performance_insights_enabled)
}

output "db_cluster_instance_performance_insights_kms_key_id" {
  description = "The ARN for the KMS encryption key used by Performance Insights."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].performance_insights_kms_key_id)
}

output "db_cluster_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = concat(aws_rds_cluster_instance.cluster_instances[*].tags)
}


# cloudwatch metric alarms
output "cpu_utilization_too_high_metric_alarm_arn" {
  description = "The ARN of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].cpu_utilization_too_high_metric_alarm_arn)
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].cpu_utilization_too_high_metric_alarm_id)
}
output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_queue_depth_too_high_metric_alarm_arn)
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_queue_depth_too_high_metric_alarm_id)
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_free_storage_space_too_low_metric_alarm_arn)
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_free_storage_space_too_low_metric_alarm_id)
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_burst_balance_too_low_metric_alarm_arn)
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].disk_burst_balance_too_low_metric_alarm_id)
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].memory_freeable_too_low_metric_alarm_arn)
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].memory_freeable_too_low_metric_alarm_id)
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].memory_swap_usage_too_high_metric_alarm_arn)
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].memory_swap_usage_too_high_metric_alarm_id)
}
output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].anomalous_connection_count_metric_alarm_id)
}
output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = concat(module.db_cloudwatch_metric_alarms[*].anomalous_connection_count_metric_alarm_arn)
}
