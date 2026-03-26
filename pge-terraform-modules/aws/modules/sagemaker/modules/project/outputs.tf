# Outputs for project

output "project_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Project."
  value       = aws_sagemaker_project.project.arn
}

output "project_name" {
  description = "The name of the Project."
  value       = aws_sagemaker_project.project.id
}

output "project_id" {
  description = "The ID of the project."
  value       = aws_sagemaker_project.project.project_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_sagemaker_project.project.tags_all
}

output "sagemaker_project_all" {
  description = "A map of aws sagemaker project"
  value       = aws_sagemaker_project.project
}