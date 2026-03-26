output "logically_air_gapped_backup_vault_id" {
  value       = module.air-gapped-vault.vault_id
  description = "The name of the AWS Backup Vault"
}

output "logically_air_gapped_backup_vault_arn" {
  value       = module.air-gapped-vault.vault_arn
  description = "The ARN of the AWS Backup vault"
}