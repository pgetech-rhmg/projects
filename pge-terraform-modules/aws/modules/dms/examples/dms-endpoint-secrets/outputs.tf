# Outputs for dms source endpoint

output "dms_source_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = module.dms_endpoint.dms_source_endpoint_arn
}

output "dms_source_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.dms_endpoint.dms_source_endpoint_tags_all
}

# Outputs for dms target endpoint

output "dms_target_endpoint_arn" {
  description = "ARN for the endpoint."
  value       = module.dms_endpoint.dms_target_endpoint_arn
}

output "dms_target_endpoint_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.dms_endpoint.dms_target_endpoint_tags_all
}

# Outputs for replication subnet group

output "vpc_id_replication_subnet_group" {
  value       = module.dms_replication_instance.vpc_id_replication_subnet_group
  description = "The ID of the VPC the subnet group is in."
}

# Outputs for replication instance 

output "replication_instance_arn" {
  value       = module.dms_replication_instance.replication_instance_arn
  description = "The Amazon Resource Name (ARN) of the replication instance."
}

output "replication_instance_private_ips" {
  value       = module.dms_replication_instance.replication_instance_private_ips
  description = "A list of the private IP addresses of the replication instance."
}

# Outputs for dms replication task

output "replication_task_arn" {
  description = "The Amazon Resource Name (ARN) for the replication task."
  value       = module.dms_replication_task.replication_task_arn
}

output "replication_task_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.dms_replication_task.replication_task_tags_all
}

output "replication_task_status" {
  description = "Status of the replication task."
  value       = module.dms_replication_task.replication_task_status
}

# Outputs for event_subscription

output "event_subscription_arn" {
  value       = module.dms_event_subscription_one.event_subscription_arn
  description = "ARN of the event subscription"
}