###############################################################################
# Outputs
###############################################################################

output "artifact_bucket_name" {
  description = "S3 bucket hosting the epic-compliance CLI binary"
  value       = module.s3_compliance_artifacts.bucket_name
}

output "artifact_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_compliance_artifacts.bucket_arn
}

output "kms_key_arn" {
  description = "KMS key ARN for artifact encryption"
  value       = aws_kms_key.compliance_artifacts.arn
}

output "artifact_s3_uri" {
  description = "Full s3:// URI of the uploaded binary (empty if not uploaded via Terraform)"
  value       = var.artifact_source != "" && var.artifact_key != "" ? "s3://${module.s3_compliance_artifacts.bucket_name}/${var.artifact_key}" : ""
}
