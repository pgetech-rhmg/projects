# Outputs for ecs capacity proivder

output "ecs_capacity_provider_id" {
  description = "The Amazon Resource Name (ARN) that identifies the capacity provider."
  value       = aws_ecs_capacity_provider.ecs_capacity_provider.id
}

output "ecs_capacity_provider_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the capacity provider."
  value       = aws_ecs_capacity_provider.ecs_capacity_provider.arn
}

output "ecs_capacity_provider_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_ecs_capacity_provider.ecs_capacity_provider.tags_all
}

output "ecs_capacity_provider_name" {
  description = "Name of the ecs capacity provider."
  value       = aws_ecs_capacity_provider.ecs_capacity_provider.name
}

output "ecs_capacity_provider_all" {
  description = "All attributes of the capacity provider."
  value       = aws_ecs_capacity_provider.ecs_capacity_provider
}