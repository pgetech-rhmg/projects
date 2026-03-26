# Map of aws_lambda_permission resource 
output "aws_lambda_permission" {
  description = "Map of aws_lambda_permission object"
  value       = aws_lambda_permission.allow_sm_invoke
}

# db_instance outputs
output "oracle_all" {
  description = "A list of map of oracle module"
  value       = [module.db_instance, module.db_option_group, module.db_parameter_group, module.db_subnet_group, module.db_cloudwatch_metric_alarms, module.secrets_manager, module.main_security_group, module.aws_iam_role, module.rotation_lambda_iam_role, module.rotation_lambda_function, module.lambda_layer]
}

output "db_instance_master_user_secret" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.db_instance.db_instance_master_user_secret
}


output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db_instance.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.db_instance.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.db_instance.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db_instance.db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.db_instance.db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.db_instance.db_instance_id
}


output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.db_instance.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.db_instance.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.db_instance.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db_instance.db_instance_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.db_instance.db_instance_port
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = module.db_instance.db_instance_ca_cert_identifier
}

output "db_instance_master_password" {
  description = "The master password"
  value       = module.db_instance.db_instance_master_password
  sensitive   = true
}
output "db_instance_host" {
  description = "The RDS address"
  value       = module.db_instance.db_instance_host
}
# db_option_group
output "db_option_group_id" {
  description = "The db option group id"
  value       = module.db_option_group.db_option_group_id
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = module.db_option_group.db_option_group_arn
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
# db_subnet_group
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.db_subnet_group.db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.db_subnet_group.db_subnet_group_arn
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

# Secrets Manager
output "secrets_manager_arn" {
  description = "ARN of the secret"
  value       = one(module.secrets_manager[*].arn)
}

output "secrets_manager_rotation_enabled" {
  description = "Whether automatic rotation is enabled for this secret"
  value       = one(module.secrets_manager[*].rotation_enabled)
}

output "secrets_manager_replica" {
  description = "Attributes of secrets manager replica are described below"
  value       = one(module.secrets_manager[*].replica)
}

output "secrets_manager_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = one(module.secrets_manager[*].version_id)
}
# Security Group
output "security_group_map" {
  description = "Map of security group object"
  value       = module.main_security_group.aws_security_group
  sensitive   = true
}

output "security_group_id" {
  description = "security group id"
  value       = module.main_security_group.sg_id
}

output "security_group_arn" {
  description = "security group id"
  value       = module.main_security_group.sg_arn
}
# IAM Role for S3 Integration
output "iam_role" {
  description = "Map of IAM Role object"
  value       = module.aws_iam_role.iam_role
}

output "iam_role_name" {
  description = "The name of the IAM role created"
  value       = module.aws_iam_role.name
}

output "iam_role_id" {
  description = "The stable and unique string identifying the role"
  value       = module.aws_iam_role.id
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = module.aws_iam_role.arn
}

output "iam_role_create_date" {
  description = "The IAM role create date"
  value       = module.aws_iam_role.create_date
}

output "iam_role_description" {
  description = "The description of the role."
  value       = module.aws_iam_role.description
}

output "rotation_lambda_iam_role" {
  description = "Map of IAM Role object"
  value       = one(module.rotation_lambda_iam_role[*].iam_role)
}

output "rotation_lambda_iam_role_name" {
  description = "The name of the IAM role created"
  value       = one(module.rotation_lambda_iam_role[*].name)
}

output "rotation_lambda_iam_role_id" {
  description = "The stable and unique string identifying the role"
  value       = one(module.rotation_lambda_iam_role[*].id)
}

output "rotation_lambda_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = one(module.rotation_lambda_iam_role[*].arn)
}

output "rotation_lambda_iam_role_create_date" {
  description = "The IAM role create date"
  value       = one(module.rotation_lambda_iam_role[*].create_date)
}

output "rotation_lambda_iam_role_description" {
  description = "The description of the role."
  value       = one(module.rotation_lambda_iam_role[*].description)
}

output "rotation_lambda_arn" {
  value       = one(module.rotation_lambda_function[*].lambda_arn)
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "rotation_lambda_invoke_arn" {
  value       = one(module.rotation_lambda_function[*].lambda_invoke_arn)
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "rotation_lambda_last_modified" {
  value       = one(module.rotation_lambda_function[*].lambda_last_modified)
  description = "Date this resource was last modified"
}

output "rotation_lambda_tags_all" {
  value       = one(module.rotation_lambda_function[*].lambda_tags_all)
  description = "A map of tags assigned to the resource"
}


# Lambda Layer
output "layer_version_arn" {
  description = "ARN of the Lambda Layer with version."
  value       = one(module.lambda_layer[*].layer_version_arn)
}

output "layer_version_created_date" {
  description = "Date this resource was created."
  value       = one(module.lambda_layer[*].layer_version_created_date)
}

output "layer_version_layer_arn" {
  description = "ARN of the Lambda Layer without version."
  value       = one(module.lambda_layer[*].layer_version_layer_arn)
}

output "layer_version_permission_id" {
  description = "The layer_name and version_number, separated by a comma (,)."
  value       = one(module.lambda_layer[*].layer_version_permission_id)
}

output "layer_version_permission_policy" {
  description = "Full Lambda Layer Permission policy."
  value       = one(module.lambda_layer[*].layer_version_permission_policy)
}

output "layer_version_permission_revision_id" {
  description = "A unique identifier for the current revision of the policy."
  value       = one(module.lambda_layer[*].layer_version_permission_revision_id)
}

output "layer_version_signing_job_arn" {
  description = "ARN of a signing job."
  value       = one(module.lambda_layer[*].layer_version_signing_job_arn)
}

output "layer_version_signing_profile_version_arn" {
  description = "ARN for a signing profile version."
  value       = one(module.lambda_layer[*].layer_version_signing_profile_version_arn)
}

output "layer_version_source_code_size" {
  description = "Size in bytes of the function .zip file."
  value       = one(module.lambda_layer[*].layer_version_source_code_size)
}

output "layer_version_version" {
  description = "Lambda Layer version."
  value       = one(module.lambda_layer[*].layer_version_version)
}




