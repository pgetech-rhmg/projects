# db_instance outputs

output "db_instance_master_user_secret" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = var.manage_master_user_password ? one(module.oracle_rds[*].oracle_all[0].aws_db_instance_this_all[0].master_user_secret[0].secret_arn) : null
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = one(module.oracle_rds[*].db_instance_address)
}
output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = one(module.oracle_rds[*].db_instance_arn)
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = one(module.oracle_rds[*].db_instance_availability_zone)
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = one(module.oracle_rds[*].db_instance_endpoint)
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = one(module.oracle_rds[*].db_instance_hosted_zone_id)
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = one(module.oracle_rds[*].db_instance_id)
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = one(module.oracle_rds[*].db_instance_resource_id)
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = one(module.oracle_rds[*].db_instance_status)
}

output "db_instance_name" {
  description = "The database name"
  value       = one(module.oracle_rds[*].db_instance_name)
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = one(module.oracle_rds[*].db_instance_username)
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = one(module.oracle_rds[*].db_instance_port)
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = one(module.oracle_rds[*].db_instance_ca_cert_identifier)
}

output "db_instance_master_password" {
  description = "The master password"
  value       = one(module.oracle_rds[*].db_instance_master_password)
  sensitive   = true
}
output "db_instance_host" {
  description = "The RDS address"
  value       = one(module.oracle_rds[*].db_instance_host)
}
# db_option_group
output "db_option_group_id" {
  description = "The db option group id"
  value       = one(module.oracle_rds[*].db_option_group_id)
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = one(module.oracle_rds[*].db_option_group_arn)
}
# db_parameter_group
output "db_parameter_group_id" {
  description = "The db parameter group name."
  value       = one(module.oracle_rds[*].db_parameter_group_id)
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = one(module.oracle_rds[*].db_parameter_group_arn)
}
# db_subnet_group
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = one(module.oracle_rds[*].db_subnet_group_id)
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = one(module.oracle_rds[*].db_subnet_group_arn)
}

# cloudwatch metric alarms
output "cpu_utilization_too_high_metric_alarm_arn" {
  description = "The ARN of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].cpu_utilization_too_high_metric_alarm_arn)
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].cpu_utilization_too_high_metric_alarm_id)
}

output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_queue_depth_too_high_metric_alarm_arn)
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_queue_depth_too_high_metric_alarm_id)
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_free_storage_space_too_low_metric_alarm_arn)
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_free_storage_space_too_low_metric_alarm_id)
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_burst_balance_too_low_metric_alarm_arn)
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].disk_burst_balance_too_low_metric_alarm_id)
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].memory_freeable_too_low_metric_alarm_arn)
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].memory_freeable_too_low_metric_alarm_id)
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].memory_swap_usage_too_high_metric_alarm_arn)
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].memory_swap_usage_too_high_metric_alarm_id)
}
output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].anomalous_connection_count_metric_alarm_id)
}
output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = one(module.oracle_rds[*].anomalous_connection_count_metric_alarm_arn)
}
# Secrets Manager
output "secrets_manager_arn" {
  description = "ARN of the secret"
  value       = one(module.oracle_rds[*].secrets_manager_arn)
}

output "secrets_manager_rotation_enabled" {
  description = "Whether automatic rotation is enabled for this secret"
  value       = one(module.oracle_rds[*].secrets_manager_rotation_enabled)
}

output "secrets_manager_replica" {
  description = "Attributes of secrets manager replica are described below"
  value       = one(module.oracle_rds[*].secrets_manager_replica)
}

output "secrets_manager_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = one(module.oracle_rds[*].secrets_manager_version_id)
}
# Security Group
output "security_group_map" {
  description = "Map of security group object"
  value       = one(module.oracle_rds[*].security_group_map)
  sensitive   = true
}

output "security_group_id" {
  description = "security group id"
  value       = one(module.oracle_rds[*].security_group_id)
}

output "security_group_arn" {
  description = "security group id"
  value       = one(module.oracle_rds[*].security_group_arn)
}
# Security Group Rules
output "ingress_security_group_rule_id" {
  description = "The ingress security group rule id."
  value       = aws_security_group_rule.ingress[*].id
}
output "egress_security_group_rule_id" {
  description = "The egress security group rule id."
  value       = aws_security_group_rule.egress[*].id
}

# IAM Role for S3 Integration
output "iam_role" {
  description = "Map of IAM Role object"
  value       = one(module.oracle_rds[*].iam_role)
}

output "iam_role_name" {
  description = "The name of the IAM role created"
  value       = one(module.oracle_rds[*].iam_role_name)
}

output "iam_role_id" {
  description = "The stable and unique string identifying the role"
  value       = one(module.oracle_rds[*].iam_role_id)
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = one(module.oracle_rds[*].iam_role_arn)
}

output "iam_role_create_date" {
  description = "The IAM role create date"
  value       = one(module.oracle_rds[*].iam_role_create_date)
}

output "iam_role_description" {
  description = "The description of the role."
  value       = one(module.oracle_rds[*].iam_role_description)
}

output "rotation_lambda_iam_role" {
  description = "Map of IAM Role object"
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role)
}

output "rotation_lambda_iam_role_name" {
  description = "The name of the IAM role created"
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role_name)
}

output "rotation_lambda_iam_role_id" {
  description = "The stable and unique string identifying the role"
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role_id)
}

output "rotation_lambda_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role_arn)
}

output "rotation_lambda_iam_role_create_date" {
  description = "The IAM role create date"
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role_create_date)
}

output "rotation_lambda_iam_role_description" {
  description = "The description of the role."
  value       = one(module.oracle_rds[*].rotation_lambda_iam_role_description)
}

output "rotation_lambda_arn" {
  value       = one(module.oracle_rds[*].rotation_lambda_arn)
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "rotation_lambda_invoke_arn" {
  value       = one(module.oracle_rds[*].rotation_lambda_invoke_arn)
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
}

output "rotation_lambda_last_modified" {
  value       = one(module.oracle_rds[*].rotation_lambda_last_modified)
  description = "Date this resource was last modified"
}

output "rotation_lambda_tags_all" {
  value       = one(module.oracle_rds[*].rotation_lambda_tags_all)
  description = "A map of tags assigned to the resource"
}

output "managed_ad_type" {
  value       = data.aws_directory_service_directory.shared.type
  description = "The Managed AD directory type."
}
output "managed_ad_name" {
  value       = data.aws_directory_service_directory.shared.name
  description = "The fully qualified name for the directory/connector."
}
output "managed_ad_alias" {
  value       = data.aws_directory_service_directory.shared.alias
  description = "The alias for the directory/connector, such as d-991708b282.awsapps.com."
}
output "managed_ad_description" {
  value       = data.aws_directory_service_directory.shared.description
  description = "A textual description for the directory/connector."
}
output "managed_ad_short_name" {
  value       = data.aws_directory_service_directory.shared.short_name
  description = "The short name of the directory/connector, such as CORP."
}
output "managed_ad_access_url" {
  value       = data.aws_directory_service_directory.shared.access_url
  description = "The access URL for the directory/connector, such as http://alias.awsapps.com."
}
output "managed_ad_rds_iam_role_id" {
  value       = data.aws_iam_role.rds_managed_ad.id
  description = "The friendly IAM role name to match."
}
output "managed_ad_rds_iam_role_arn" {
  value       = data.aws_iam_role.rds_managed_ad.arn
  description = "The Amazon Resource Name (ARN) specifying the role."
}
output "managed_ad_rds_iam_role_description" {
  value       = data.aws_iam_role.rds_managed_ad.description
  description = "Description for the role."
}

#Lambda Layer
output "layer_version_arn" {
  description = "ARN of the Lambda Layer with version."
  value       = one(module.oracle_rds[*].layer_version_arn)
}

output "layer_version_created_date" {
  description = "Date this resource was created."
  value       = one(module.oracle_rds[*].layer_version_created_date)
}

output "layer_version_layer_arn" {
  description = "ARN of the Lambda Layer without version."
  value       = one(module.oracle_rds[*].layer_version_layer_arn)
}

output "layer_version_permission_id" {
  description = "The layer_name and version_number, separated by a comma (,)."
  value       = one(module.oracle_rds[*].layer_version_permission_id)
}

output "layer_version_permission_policy" {
  description = "Full Lambda Layer Permission policy."
  value       = one(module.oracle_rds[*].layer_version_permission_policy)
}

output "layer_version_permission_revision_id" {
  description = "A unique identifier for the current revision of the policy."
  value       = one(module.oracle_rds[*].layer_version_permission_revision_id)
}

output "layer_version_signing_job_arn" {
  description = "ARN of a signing job."
  value       = one(module.oracle_rds[*].layer_version_signing_job_arn)
}

output "layer_version_signing_profile_version_arn" {
  description = "ARN for a signing profile version."
  value       = one(module.oracle_rds[*].layer_version_signing_profile_version_arn)
}

output "layer_version_source_code_size" {
  description = "Size in bytes of the function .zip file."
  value       = one(module.oracle_rds[*].layer_version_source_code_size)
}

output "layer_version_version" {
  description = "Lambda Layer version."
  value       = one(module.oracle_rds[*].layer_version_version)
}
