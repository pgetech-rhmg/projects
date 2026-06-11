output "key_id" {
  description = "KMS key ID."
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "KMS key ARN."
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "KMS key alias name."
  value       = aws_kms_alias.this.name
}

output "alias_arn" {
  description = "KMS key alias ARN."
  value       = aws_kms_alias.this.arn
}

output "key_rotation_enabled" {
  description = "Whether automatic key rotation is enabled."
  value       = aws_kms_key.this.enable_key_rotation
}
