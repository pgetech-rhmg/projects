output "arn" {
  description = "ARN of the secret"
  value       = module.secretsmanager.arn
}


output "version_id" {
  description = "The unique identifier of the version of the secret"
  value       = module.secretsmanager[*].version_id
}