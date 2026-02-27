output "arn" {
  description = "Secrets Manager ARN"
  value       = aws_secretsmanager_secret.sm.arn
}

output "rotation_enabled" {
  description = "Whether rotation is enabled"
  value       = var.rotation_enabled
}

output "version_ids" {
  description = "Map of secret version IDs"
  value = {
    for k, v in aws_secretsmanager_secret_version.sm_secret_version :
    k => v.version_id
  }
}

output "secrets" {
  description = "Full secrets manager objects"
  value       = aws_secretsmanager_secret.sm
}

output "secret_read_arn" {
  description = "Secrets Manager READ ARN"
  value       = aws_iam_policy.secret_read.arn
}
