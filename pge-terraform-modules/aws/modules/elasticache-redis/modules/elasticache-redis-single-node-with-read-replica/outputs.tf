# Outputs for aws_elasticache_replication_group

output "replication_group_arn" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.arn
  description = "ARN of the created ElastiCache Replication Group."
}

output "replication_group_engine_version_actual" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.engine_version_actual
  description = "Running version of the cache engine."
}

output "replication_group_cluster_enabled" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.cluster_enabled
  description = "Indicates if cluster mode is enabled."
}

output "replication_group_configuration_endpoint_address" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.configuration_endpoint_address
  description = "Address of the replication group configuration endpoint when cluster mode is enabled."
}

output "replication_group_id" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.id
  description = " ID of the ElastiCache Replication Group."
}

output "replication_group_member_clusters" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.member_clusters
  description = "Identifiers of all the nodes that are part of this replication group."
}

output "replication_group_primary_endpoint_address" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address
  description = "Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
}

output "replication_group_reader_endpoint_address" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.reader_endpoint_address
  description = "Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
}

output "replication_group_tags_all" {
  value       = aws_elasticache_replication_group.elasticache_replication_group.tags_all
  description = " Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}

# Outputs for aws_elasticache_cluster

output "arn" {
  value       = aws_elasticache_cluster.read_replica_single_node.arn
  description = "The ARN of the created ElastiCache Cluster"
}

output "engine_version_actual" {
  value       = aws_elasticache_cluster.read_replica_single_node.engine_version_actual
  description = " The running version of the cache engine."
}

output "cache_nodes" {
  value       = aws_elasticache_cluster.read_replica_single_node.cache_nodes
  description = " List of node objects"
}

output "cluster_address" {
  value       = aws_elasticache_cluster.read_replica_single_node.cluster_address
  description = "DNS name of the cache cluster without the port appended."
}

output "configuration_endpoint" {
  description = "Configuration endpoint to allow host discovery."
  value       = aws_elasticache_cluster.read_replica_single_node.configuration_endpoint
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_elasticache_cluster.read_replica_single_node.tags_all
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
