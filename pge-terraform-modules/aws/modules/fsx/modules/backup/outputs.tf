output "fsx_backup_arn" {
  description = "Amazon Resource Name of the backup."
  value       = aws_fsx_backup.fsx_backup.arn
}

output "fsx_backup_id" {
  description = "Identifier of the backup"
  value       = aws_fsx_backup.fsx_backup.id
}

output "fsx_backup_kms_key_id" {
  description = "The ID of the AWS Key Management Service (AWS KMS) key used to encrypt the backup of the Amazon FSx file system's data at rest."
  value       = aws_fsx_backup.fsx_backup.kms_key_id
}

output "fsx_backup_owner_id" {
  description = "AWS account identifier that created the file system."
  value       = aws_fsx_backup.fsx_backup.owner_id
}

output "fsx_backup_tags_all" {
  description = "AWS account identifier that created the file system."
  value       = aws_fsx_backup.fsx_backup.tags_all
}

output "fsx_backup_type" {
  description = "The type of the file system backup."
  value       = aws_fsx_backup.fsx_backup.type
}