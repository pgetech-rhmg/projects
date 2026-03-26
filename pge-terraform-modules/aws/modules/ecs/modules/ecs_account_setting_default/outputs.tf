# Outputs for ecs account setting default

output "ecs_account_setting_default_id" {
  description = "ARN that identifies the account setting."
  value       = aws_ecs_account_setting_default.ecs_account_setting_default.id
}

output "ecs_account_setting_default_principal_arn" {
  description = "ARN that identifies the account setting."
  value       = aws_ecs_account_setting_default.ecs_account_setting_default.principal_arn
}

output "ecs_account_setting_default_all" {
  description = "All attributes of the account setting."
  value       = aws_ecs_account_setting_default.ecs_account_setting_default
}