output "fsx_windows_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = module.windows_file_system.fsx_windows_file_system_arn
}

output "fsx_windows_file_system_id" {
  description = "Identifier of the file system."
  value       = module.windows_file_system.fsx_windows_file_system_id
}

#outputs for backup
output "fsx_backup_arn" {
  description = "Amazon Resource Name of the backup."
  value       = module.windows_backup.fsx_backup_arn
}

output "fsx_backup_id" {
  description = "Identifier of the backup"
  value       = module.windows_backup.fsx_backup_id
}
