output "key_arn" {
  description = "KMS key arn"
  value       = module.kms_key.key_arn
}

output "key_id" {
  description = "KMS ID"
  value       = module.kms_key.key_id
}