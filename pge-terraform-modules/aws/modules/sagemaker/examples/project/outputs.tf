# Outputs for Project

output "project_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Project."
  value       = module.project.project_arn
}

output "project_name" {
  description = "The name of the Project."
  value       = module.project.project_name
}

output "project_id" {
  description = "The ID of the project."
  value       = module.project.project_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = module.project.tags_all
}