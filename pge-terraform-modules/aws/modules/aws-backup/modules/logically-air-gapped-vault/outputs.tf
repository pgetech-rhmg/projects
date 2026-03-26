output "vault_id" {
  value       = aws_backup_logically_air_gapped_vault.default.id
  description = "The name of the vault"
}

output "vault_arn" {
  value       = aws_backup_logically_air_gapped_vault.default.arn
  description = "The ARN of the vault"
}

output "vault_all" {
  value       = aws_backup_logically_air_gapped_vault.default
  description = "All parameters of vault"
}