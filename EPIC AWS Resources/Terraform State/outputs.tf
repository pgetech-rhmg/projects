###############################################################################
# Outputs
###############################################################################

output "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = module.s3_terraform_state.bucket_name
}

output "state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_terraform_state.bucket_arn
}

output "kms_key_id" {
  description = "KMS key ID for state encryption"
  value       = aws_kms_key.terraform_state.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for state encryption"
  value       = aws_kms_key.terraform_state.arn
}

output "epic_service_role_arn" {
  description = "ARN of EPIC service role (use this in epic-target-bootstrap)"
  value       = aws_iam_role.epic_service.arn
}

output "epic_service_role_name" {
  description = "Name of EPIC service role"
  value       = aws_iam_role.epic_service.name
}
