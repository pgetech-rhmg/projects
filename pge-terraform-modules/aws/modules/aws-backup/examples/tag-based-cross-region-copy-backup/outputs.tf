output "vault_id" {
  value       = module.aws-backup-vault.vault_id
  description = "The name of the vault"
}

output "vault_arn" {
  value       = module.aws-backup-vault.vault_arn
  description = "The ARN of the vault"
}

output "vault_recovery_points" {
  value       = module.aws-backup-vault.vault_recovery_points
  description = "The number of recovery points that are stored in a backup vault"
}

output "vault_id_replica" {
  value       = module.aws-backup-vault-replica.vault_id
  description = "The name of the vault"
}

output "vault_arn_replica" {
  value       = module.aws-backup-vault-replica.vault_arn
  description = "The ARN of the vault"
}

output "vault_recovery_points_replica" {
  value       = module.aws-backup-vault-replica.vault_recovery_points
  description = "The number of recovery points that are stored in a backup vault"
}

output "backup_plan_id" {
  value       = module.aws-backup-plan.backup_plan_id
  description = "The id of the backup plan"
}

output "backup_plan_arn" {
  value       = module.aws-backup-plan.backup_plan_arn
  description = "The ARN of the backup plan"
}

output "backup_plan_version" {
  value       = module.aws-backup-plan.backup_plan_version
  description = "Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan"
}



