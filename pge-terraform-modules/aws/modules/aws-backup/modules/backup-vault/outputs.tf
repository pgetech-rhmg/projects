output "vault_id" {
  value       = aws_backup_vault.default.id
  description = "The name of the vault"
}

output "vault_arn" {
  value       = aws_backup_vault.default.arn
  description = "The ARN of the vault"
}

output "vault_recovery_points" {
  value       = aws_backup_vault.default.recovery_points
  description = "The number of recovery points that are stored in a backup vault"
}

output "vault_all" {
  value       = aws_backup_vault.default
  description = "All parameters of vault"
}