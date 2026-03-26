# Outputs for ecs task definition

output "ecs_task_definition_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.ecs_task_definition.arn
}

output "ecs_task_definition_family" {
  description = "The family of the Task Definition."
  value       = aws_ecs_task_definition.ecs_task_definition.family
}

output "ecs_task_definition_revision" {
  description = "Revision of the task in a particular family."
  value       = aws_ecs_task_definition.ecs_task_definition.revision
}

output "ecs_task_definition_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_ecs_task_definition.ecs_task_definition.tags_all
}

output "ecs_task_definition_all" {
  description = "Map of ECS task-definition object"
  value       = aws_ecs_task_definition.ecs_task_definition
}