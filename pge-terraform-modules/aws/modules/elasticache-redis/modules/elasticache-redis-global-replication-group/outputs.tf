# Outputs for aws_elasticache_global_replication_group

output "global_replication_group_id" {
  value       = aws_elasticache_global_replication_group.global.id
  description = "The ID of the ElastiCache Global Replication Group."
}

output "global_replication_group_arn" {
  value       = aws_elasticache_global_replication_group.global.arn
  description = "The ARN of the ElastiCache Global Replication Group."
}

output "global_replication_group_engine_version_actual" {
  value       = aws_elasticache_global_replication_group.global.engine_version_actual
  description = "The full version number of the cache engine running on the members of this global replication group"
}

output "global_replication_group_at_rest_encryption_enabled" {
  value       = aws_elasticache_global_replication_group.global.at_rest_encryption_enabled
  description = "A flag that indicate whether the encryption at rest is enabled."
}

output "global_replication_group_auth_token_enabled" {
  value       = aws_elasticache_global_replication_group.global.auth_token_enabled
  description = "A flag that indicate whether AuthToken (password) is enabled."
}

output "global_replication_group_cache_node_type" {
  value       = aws_elasticache_global_replication_group.global.cache_node_type
  description = "The instance class used"
}

output "global_replication_group_cluster_enabled" {
  value       = aws_elasticache_global_replication_group.global.cluster_enabled
  description = "Indicates whether the Global Datastore is cluster enabled."
}

output "global_replication_group_engine" {
  description = "The name of the cache engine to be used for the clusters in this global replication group."
  value       = aws_elasticache_global_replication_group.global.engine
}

output "global_replication_group_global_replication_group_id" {
  description = "The full ID of the global replication group."
  value       = aws_elasticache_global_replication_group.global.global_replication_group_id
}

output "global_replication_group_transit_encryption_enabled" {
  description = "A flag that indicates whether the encryption in transit is enabled."
  value       = aws_elasticache_global_replication_group.global.transit_encryption_enabled
}

