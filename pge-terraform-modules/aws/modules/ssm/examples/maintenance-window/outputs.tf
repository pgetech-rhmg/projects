output "maintenance_window_id" {
  description = "SSM Patch Manager patch group ID"
  value       = module.maintenance-window.window_id
}

output "maintenance_window_target_id" {
  description = "SSM Patch Manager patch group ID"
  value       = module.maintenance-window[*].window_target_id
}

output "maintenance_window_tasks_run_command_arn" {
  description = "The ARN of the maintenance window task"
  value       = module.maintenance-window-tasks-run-command.arn
}

output "maintenance_window_tasks_run_command_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-run-command.id
}

output "maintenance_window_tasks_run_command_window_task_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-run-command.window_task_id
}

output "maintenance_window_tasks_automation_arn" {
  description = "The ARN of the maintenance window task"
  value       = module.maintenance-window-tasks-automation.arn
}

output "maintenance_window_tasks_automation_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-automation.id
}

output "maintenance_window_tasks_automation_window_task_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-automation.window_task_id
}

output "maintenance_window_tasks_lambda_arn" {
  description = "The ARN of the maintenance window task"
  value       = module.maintenance-window-tasks-lambda.arn
}

output "maintenance_window_tasks_lambda_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-lambda.id
}

output "maintenance_window_tasks_lambda_window_task_id" {
  description = "The ID of the maintenance window task"
  value       = module.maintenance-window-tasks-lambda.window_task_id
}



