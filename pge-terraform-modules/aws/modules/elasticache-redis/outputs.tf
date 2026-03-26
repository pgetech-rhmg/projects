# Outputs for aws_elasticache_cluster

output "arn" {
  value       = aws_elasticache_cluster.redis_single_node.arn
  description = "The ARN of the created ElastiCache Cluster"
}

output "engine_version_actual" {
  value       = aws_elasticache_cluster.redis_single_node.engine_version_actual
  description = " The running version of the cache engine."
}

output "cache_nodes" {
  value       = aws_elasticache_cluster.redis_single_node.cache_nodes
  description = " List of node objects"
}

output "cluster_address" {
  value       = aws_elasticache_cluster.redis_single_node.cluster_address
  description = "DNS name of the cache cluster without the port appended."
}

output "configuration_endpoint" {
  description = "Configuration endpoint to allow host discovery."
  value       = aws_elasticache_cluster.redis_single_node.configuration_endpoint
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_elasticache_cluster.redis_single_node.tags_all
}

# Outputs for aws_elasticache_parameter_group

output "parameter_group_id" {
  value       = aws_elasticache_parameter_group.paragroup[*].id
  description = "The ElastiCache parameter group name."
}

output "parameter_group_arn" {
  value       = aws_elasticache_parameter_group.paragroup[*].arn
  description = "The AWS ARN associated with the parameter group."
}

output "parameter_group_tags_all" {
  value       = aws_elasticache_parameter_group.paragroup[*].tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

# Outputs for aws_elasticache_subnet_group

output "subnet_group_description" {
  value       = aws_elasticache_subnet_group.redis.description
  description = "The Description of the ElastiCache Subnet Group."
}

output "subnet_group_name" {
  value       = aws_elasticache_subnet_group.redis.name
  description = "The Name of the ElastiCache Subnet Group"
}

output "subnet_group_subnet_ids" {
  value       = aws_elasticache_subnet_group.redis.subnet_ids
  description = "The Subnet IDs of the ElastiCache Subnet Group"
}

output "subnet_group_tags_all" {
  value       = aws_elasticache_subnet_group.redis.tags_all
  description = "A map of tags assigned to the resource"
}

