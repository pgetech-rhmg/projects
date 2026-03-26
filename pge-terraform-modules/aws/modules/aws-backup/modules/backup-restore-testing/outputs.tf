output "restore_testing_plan_arn" {
  value       = aws_backup_restore_testing_plan.default.arn
  description = "The ARN of the restore testing plan"
}
