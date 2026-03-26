output "id" {
  description = "Backup Selection identifier"
  value       = aws_backup_selection.backup_selection.id
}

output "all" {
  description = "All attributes of Backup Selection identifier"
  value       = aws_backup_selection.backup_selection
}