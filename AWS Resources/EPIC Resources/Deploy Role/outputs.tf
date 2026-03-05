###############################################################################
# Outputs
###############################################################################

output "epic_deployment_role_arn" {
  description = "ARN of the EPIC deployment role"
  value       = aws_iam_role.epic_deployment.arn
}

output "epic_deployment_role_name" {
  description = "Name of the EPIC deployment role"
  value       = aws_iam_role.epic_deployment.name
}
