# Outputs for aws_elasticache_parameter_group

output "parameter_group_id" {
  value       = module.redis_multi_node[*].parameter_group_id
  description = "The ElastiCache parameter group name."
}

output "parameter_group_arn" {
  value       = module.redis_multi_node[*].parameter_group_arn
  description = "The AWS ARN associated with the parameter group."
}

output "parameter_group_tags_all" {
  value       = module.redis_multi_node[*].parameter_group_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

# Outputs for aws_elasticache_subnet_group

output "subnet_group_description" {
  value       = module.redis_multi_node.subnet_group_description
  description = "The Description of the ElastiCache Subnet Group."
}

output "subnet_group_name" {
  value       = module.redis_multi_node.subnet_group_name
  description = "The Name of the ElastiCache Subnet Group"
}

output "subnet_group_subnet_ids" {
  value       = module.redis_multi_node.subnet_group_subnet_ids
  description = "The Subnet IDs of the ElastiCache Subnet Group"
  sensitive   = true
}

output "subnet_group_tags_all" {
  value       = module.redis_multi_node.subnet_group_tags_all
  description = "A map of tags assigned to the resource"
}

# Variables for replication group

output "replication_group_arn" {
  value       = module.redis_multi_node[*].replication_group_arn
  description = "ARN of the created ElastiCache Replication Group."
}

output "replication_group_engine_version_actual" {
  value       = module.redis_multi_node[*].replication_group_engine_version_actual
  description = "Running version of the cache engine."
}

output "replication_group_cluster_enabled" {
  value       = module.redis_multi_node[*].replication_group_cluster_enabled
  description = "Indicates if cluster mode is enabled."
}

output "replication_group_configuration_endpoint_address" {
  value       = module.redis_multi_node[*].replication_group_configuration_endpoint_address
  description = "Address of the replication group configuration endpoint when cluster mode is enabled."
}

output "replication_group_id" {
  value       = module.redis_multi_node[*].replication_group_id
  description = " ID of the ElastiCache Replication Group."
}

output "replication_group_member_clusters" {
  value       = module.redis_multi_node[*].replication_group_member_clusters
  description = "Identifiers of all the nodes that are part of this replication group."
}

output "replication_group_primary_endpoint_address" {
  value       = module.redis_multi_node[*].replication_group_primary_endpoint_address
  description = "Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
}

output "replication_group_reader_endpoint_address" {
  value       = module.redis_multi_node[*].replication_group_reader_endpoint_address
  description = "Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
}

output "replication_group_tags_all" {
  value       = module.redis_multi_node[*].replication_group_tags_all
  description = " Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}

