output "backup_plan_id" {
  value       = aws_backup_plan.default.id
  description = "The id of the backup plan"
}

output "backup_plan_arn" {
  value       = aws_backup_plan.default.arn
  description = "The ARN of the backup plan"
}

output "backup_plan_version" {
  value       = aws_backup_plan.default.version
  description = "Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan"
}

output "backup_plan_all" {
  value       = aws_backup_plan.default
  description = "All parameters of the backup plan"
}