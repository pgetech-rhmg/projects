output "arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.sm.arn
}

output "rotation_enabled" {
  description = "Whether automatic rotation is enabled for this secret"
  value       = var.rotation_enabled
}

output "replica" {
  description = "Attributes of a replica are described below"
  value       = aws_secretsmanager_secret.sm.replica
}

output "secret_version_enabled" {
  description = "The version of the secret"
  value       = var.secret_version_enabled
}

output "version_id" {
  description = "The unique identifier of the version of the secret"
  value       = aws_secretsmanager_secret_version.sm_secret_version[*].version_id
}

output "aws_secretsmanager_secret" {
  description = "Map of aws_secretsmanager_secret object"
  value       = aws_secretsmanager_secret.sm
}

output "aws_secretsmanager_secret_rotation" {
  description = "Map of aws_secretsmanager_secret object"
  value       = var.rotation_enabled ? aws_secretsmanager_secret_rotation.sm_secret_rotation : null
}

output "aws_secretsmanager_secret_version" {
  description = "Map of aws_secretsmanager_secret object"
  value       = var.secret_version_enabled ? aws_secretsmanager_secret_version.sm_secret_version : null
}
