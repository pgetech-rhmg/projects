# Outputs for aws_elasticache_cluster

output "arn" {
  value       = module.redis_single_node[*].arn
  description = "The ARN of the created ElastiCache Cluster"
}

output "engine_version_actual" {
  value       = module.redis_single_node[*].engine_version_actual
  description = " The running version of the cache engine."
}

output "cache_nodes" {
  value       = module.redis_single_node[*].cache_nodes
  description = " List of node objects"
}

output "cluster_address" {
  value       = module.redis_single_node[*].cluster_address
  description = "DNS name of the cache cluster without the port appended."
}

output "configuration_endpoint" {
  description = "Configuration endpoint to allow host discovery."
  value       = module.redis_single_node[*].configuration_endpoint
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider"
  value       = module.redis_single_node.tags_all
}

# Outputs for aws_elasticache_parameter_group

output "parameter_group_id" {
  value       = module.redis_single_node[*].parameter_group_id
  description = "The ElastiCache parameter group name."
}

output "parameter_group_arn" {
  value       = module.redis_single_node[*].parameter_group_arn
  description = "The AWS ARN associated with the parameter group."
}

output "parameter_group_tags_all" {
  value       = module.redis_single_node[*].parameter_group_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

# Outputs for aws_elasticache_subnet_group

output "subnet_group_description" {
  value       = module.redis_single_node.subnet_group_description
  description = "The Description of the ElastiCache Subnet Group."
}

output "subnet_group_name" {
  value       = module.redis_single_node.subnet_group_name
  description = "The Name of the ElastiCache Subnet Group"
}

output "subnet_group_subnet_ids" {
  value       = module.redis_single_node.subnet_group_subnet_ids
  sensitive   = true
  description = "The Subnet IDs of the ElastiCache Subnet Group"
}

output "subnet_group_tags_all" {
  value       = module.redis_single_node.subnet_group_tags_all
  description = "A map of tags assigned to the resource"
}




