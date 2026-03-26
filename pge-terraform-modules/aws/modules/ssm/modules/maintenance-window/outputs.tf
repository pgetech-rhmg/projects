output "window_id" {
  description = "SSM Patch Manager patch group ID"
  value       = aws_ssm_maintenance_window.window.id
}

output "window_target_id" {
  description = "SSM Patch Manager patch group ID"
  value       = aws_ssm_maintenance_window_target.target[*].id
}