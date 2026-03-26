output "workforce_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Workforce."
  value       = aws_sagemaker_workforce.sagemaker_workforce.arn
}

output "workforce_id" {
  description = "The name of the Workforce."
  value       = aws_sagemaker_workforce.sagemaker_workforce.id
}

output "workforce_subdomain" {
  description = "The subdomain for your OIDC Identity Provider."
  value       = aws_sagemaker_workforce.sagemaker_workforce.subdomain
}

output "sagemaker_workforce_all" {
  description = "A map of aws sagemaker workforce"
  value       = aws_sagemaker_workforce.sagemaker_workforce
}