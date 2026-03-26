output "workforce_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Workforce."
  value       = module.sagemaker_workforce.workforce_arn
}

output "workforce_id" {
  description = "The name of the Workforce."
  value       = module.sagemaker_workforce.workforce_id
}

output "workforce_subdomain" {
  description = "The subdomain for your OIDC Identity Provider."
  value       = module.sagemaker_workforce.workforce_subdomain
}