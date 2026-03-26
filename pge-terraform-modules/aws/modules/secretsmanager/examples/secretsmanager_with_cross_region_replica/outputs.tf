output "arn" {
  description = "ARN of the secret"
  value       = module.secretsmanager.arn
}


output "replica" {
  description = "Attributes of a replica are described below"
  value       = module.secretsmanager.replica
}