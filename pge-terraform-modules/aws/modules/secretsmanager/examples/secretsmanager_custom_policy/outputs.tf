output "arn" {
  description = "ARN of the secret"
  value       = module.secretsmanager.arn
}