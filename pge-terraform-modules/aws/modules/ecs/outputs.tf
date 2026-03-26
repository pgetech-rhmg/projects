# Outputs for ecs cluster

output "ecs_cluster_id" {
  description = "ID of the ECS Cluster."
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster."
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "ecs_cluster_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_ecs_cluster.ecs_cluster.tags_all
}

# Outputs for ecs cluster capacity providers

output "ecs_cluster_capacity_providers_id" {
  description = "Same as cluster_name."
  value       = aws_ecs_cluster_capacity_providers.ecs_cluster_capacity_providers.id
}

output "ecs_cluster_all" {
  description = "Map of ECS cluster object"
  value       = aws_ecs_cluster.ecs_cluster
}