# Outputs for ecs task set

output "ecs_task_id" {
  description = "The task_set_id, service and cluster separated by commas (,)."
  value       = aws_ecs_task_set.ecs_task_set[*].id
}

output "ecs_task_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the task set."
  value       = aws_ecs_task_set.ecs_task_set[*].arn
}

output "ecs_task_set_stability_status" {
  description = "The stability status. This indicates whether the task set has reached a steady state."
  value       = aws_ecs_task_set.ecs_task_set[*].stability_status
}

output "ecs_task_set_status" {
  description = "The status of the task set."
  value       = aws_ecs_task_set.ecs_task_set[*].status
}

output "ecs_task_set_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_ecs_task_set.ecs_task_set[*].tags_all
}

output "ecs_task_set_id" {
  description = "The status of the task set."
  value       = aws_ecs_task_set.ecs_task_set[*].task_set_id
}

output "ecs_task_set_all" {
  description = "Map of ECS task-set object"
  value       = aws_ecs_task_set.ecs_task_set
}