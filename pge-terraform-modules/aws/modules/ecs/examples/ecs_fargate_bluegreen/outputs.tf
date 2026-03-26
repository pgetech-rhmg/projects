# Outputs for ecs cluster

output "ecs_cluster_id" {
  description = "ID of the ECS Cluster."
  value       = module.ecs_fargate.ecs_cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster."
  value       = module.ecs_fargate.ecs_cluster_arn
}

output "ecs_cluster_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.ecs_fargate.ecs_cluster_tags_all
}

# Outputs for ecs cluster capacity providers

output "ecs_cluster_capacity_providers_id" {
  description = "Same as cluster_name."
  value       = module.ecs_fargate.ecs_cluster_capacity_providers_id
}

# Outputs for ecs task definition
output "ecs_task_definition_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = module.ecs_task_definition.ecs_task_definition_arn
}

output "ecs_task_definition_revision" {
  description = "Revision of the task in a particular family."
  value       = module.ecs_task_definition.ecs_task_definition_revision
}

output "ecs_task_definition_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.ecs_task_definition.ecs_task_definition_tags_all
}

output "wiz_container_name" {
  description = "Name of the wiz container."
  value       = module.ecs_fargate.wiz_container_name
}

output "wiz_container_definition_json" {
  description = "JSON encoded list of container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = module.ecs_fargate.wiz_container_definition_json
}

# Output of Container definitions - Container name

output "container_name" {
  description = "Name of the container"
  value       = module.container.container_name
}

# Outputs for ecs service 

output "ecs_service_cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = module.ecs_service.ecs_service_cluster
}

output "ecs_service_desired_count" {
  description = "Number of instances of the task definition."
  value       = module.ecs_service.ecs_service_desired_count
}

output "ecs_service_iam_role" {
  description = "ARN of IAM role used for ELB."
  value       = module.ecs_service.ecs_service_iam_role
}

output "ecs_service_id" {
  description = "ARN that identifies the service."
  value       = module.ecs_service.ecs_service_id
}

output "ecs_service_name" {
  description = "Name of the service."
  value       = module.ecs_service.ecs_service_name
}

output "ecs_service_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.ecs_service.ecs_service_tags_all
}

# Outputs for ecs account setting default

output "ecs_account_setting_default_id" {
  description = "ARN that identifies the account setting."
  value       = module.ecs_account_setting_default.ecs_account_setting_default_id
}

output "ecs_account_setting_default_principal_arn" {
  description = "ARN that identifies the account setting."
  value       = module.ecs_account_setting_default.ecs_account_setting_default_principal_arn
}

