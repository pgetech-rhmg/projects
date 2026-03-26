output "sqlserver_all" {
  description = "A list of map of all sqlserver module attributes"
  value       = [module.db_instance, module.db_subnet_group, module.db_parameter_group, module.main_security_group, module.db_cloudwatch_metric_alarms, module.ssm_parameter]
}

output "db_instance_identifier" {
  description = "The identifier of the DB instance"
  value       = module.db_instance.db_instance_identifier
}

output "db_instance_master_user_secret" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.db_instance.db_instance_master_user_secret
}

output "db_instance_address" {
  description = "The address of the RDS instance."
  value       = module.db_instance.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = module.db_instance.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance."
  value       = module.db_instance.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint."
  value       = module.db_instance.db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)."
  value       = module.db_instance.db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID."
  value       = module.db_instance.db_instance_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance."
  value       = module.db_instance.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status."
  value       = module.db_instance.db_instance_status
}

output "db_instance_name" {
  description = "The database name."
  value       = module.db_instance.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database."
  value       = module.db_instance.db_instance_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port."
  value       = module.db_instance.db_instance_port
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance."
  value       = module.db_instance.db_instance_ca_cert_identifier
}


output "db_instance_master_password" {
  description = "The master password."
  value       = module.db_instance.db_instance_master_password
  sensitive   = true
}
output "db_instance_host" {
  description = "The RDS address."
  value       = module.db_instance.db_instance_host
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
  value       = module.db_cloudwatch_metric_alarms.cpu_utilization_too_high_metric_alarm_arn
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.cpu_utilization_too_high_metric_alarm_id
}
output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_queue_depth_too_high_metric_alarm_arn
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_queue_depth_too_high_metric_alarm_id
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_free_storage_space_too_low_metric_alarm_arn
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_free_storage_space_too_low_metric_alarm_id
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_burst_balance_too_low_metric_alarm_arn
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.disk_burst_balance_too_low_metric_alarm_id
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.memory_freeable_too_low_metric_alarm_arn
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.memory_freeable_too_low_metric_alarm_id
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.memory_swap_usage_too_high_metric_alarm_arn
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.memory_swap_usage_too_high_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.anomalous_connection_count_metric_alarm_id
}
output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = module.db_cloudwatch_metric_alarms.anomalous_connection_count_metric_alarm_arn
}

# Storage of db password
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
