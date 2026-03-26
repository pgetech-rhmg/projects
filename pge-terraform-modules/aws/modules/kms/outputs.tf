# Module      : KMS KEY
# Description : This terraform module creates a KMS Customer Master Key (CMK) and its alias.
output "kms_key" {
  value       = aws_kms_key.default
  description = "Map of KMS key object"
}

output "kms_alias" {
  value       = aws_kms_alias.default
  description = "Map of KMS Alias object"
}

output "key_arn" {
  value       = join("", aws_kms_key.default.*.arn)
  description = "Key ARN."
}

output "key_id" {
  value       = join("", aws_kms_key.default.*.key_id)
  description = "Key ID."
}

output "alias_arn" {
  value       = join("", aws_kms_alias.default.*.arn)
  description = "Alias ARN."
}

output "alias_name" {
  value       = join("", aws_kms_alias.default.*.name)
  description = "Alias name."
}
