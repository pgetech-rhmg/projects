# Outputs for workteam

output "workteam_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Workteam."
  value       = aws_sagemaker_workteam.workteam.arn
}

output "workteam_id" {
  description = "The name of the Workteam."
  value       = aws_sagemaker_workteam.workteam.id
}

output "workteam_subdomain" {
  description = "The subdomain for your OIDC Identity Provider."
  value       = aws_sagemaker_workteam.workteam.subdomain
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_workteam.workteam.tags_all
}

output "sagemaker_workteam_all" {
  description = "A map of aws sagemaker workteam"
  value       = aws_sagemaker_workteam.workteam
}