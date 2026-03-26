# Outputs for ecs service 

output "ecs_service_cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_service.ecs_service.cluster
}

output "ecs_service_desired_count" {
  description = "Number of instances of the task definition."
  value       = aws_ecs_service.ecs_service.desired_count
}

output "ecs_service_iam_role" {
  description = "ARN of IAM role used for ELB."
  value       = aws_ecs_service.ecs_service.iam_role
}

output "ecs_service_id" {
  description = "ARN that identifies the service."
  value       = aws_ecs_service.ecs_service.id
}

output "ecs_service_name" {
  description = "Name of the service."
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_service_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_ecs_service.ecs_service.tags_all
}

output "ecs_service_all" {
  description = "Map of ECS service object"
  value       = aws_ecs_service.ecs_service
}