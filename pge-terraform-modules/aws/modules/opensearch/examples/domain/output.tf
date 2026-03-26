output "domain_arn" {
  description = "The Domain ARN"
  value       = module.domain.domain_arn
}

output "domain_dashboard_endpoint" {
  description = "Domain Dashboard endpoint"
  value       = module.domain.domain_dashboard_endpoint
}

output "domain_endpoint" {
  description = "Domain-specific endpoint for Dashboard without https scheme"
  value       = module.domain.domain_endpoint
}

output "domain_id" {
  description = "Unique identifier for the domain."
  value       = module.domain.domain_id
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = module.domain.domain_name
}
