# Outputs for workteam

output "workteam_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Workteam."
  value       = module.workteam.workteam_arn
}

output "workteam_id" {
  description = "The name of the Workteam."
  value       = module.workteam.workteam_id
}

output "workteam_subdomain" {
  description = "The subdomain for your OIDC Identity Provider."
  value       = module.workteam.workteam_subdomain
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.workteam.tags_all
}