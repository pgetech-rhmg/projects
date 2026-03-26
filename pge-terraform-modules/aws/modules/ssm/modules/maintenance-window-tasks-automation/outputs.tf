output "all" {
  description = "The map of all output attributes"
  value       = aws_ssm_maintenance_window_task.task_patches
}

output "arn" {
  description = "The ARN of the maintenance window task"
  value       = aws_ssm_maintenance_window_task.task_patches.arn
}

output "id" {
  description = "The ID of the maintenance window task"
  value       = aws_ssm_maintenance_window_task.task_patches.id
}

output "window_task_id" {
  description = "The ID of the maintenance window task"
  value       = aws_ssm_maintenance_window_task.task_patches.window_task_id
}
