# Outputs for Amplify Backend Environment

output "arn" {
  description = "ARN for a backend environment that is part of an Amplify app."
  value       = aws_amplify_backend_environment.amplify_backend_environment.arn
}

output "id" {
  description = "Unique ID of the Amplify backend environment."
  value       = aws_amplify_backend_environment.amplify_backend_environment.id
}

output "amplify_backend_environment_all" {
  description = "A map of aws amplify backend environment"
  value       = aws_amplify_backend_environment.amplify_backend_environment
}