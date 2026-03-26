output "domain_id" {
  description = "Unique identifier (ID) of the Domain."
  value       = aws_opensearch_domain.domain.domain_id
}

output "domain_arn" {
  description = "ARN of the Domain"
  value       = aws_opensearch_domain.domain.arn
}

output "domain_name" {
  description = "Name of the Domain"
  value       = aws_opensearch_domain.domain.domain_name
}

output "domain_endpoint" {
  description = "Domain endpoint"
  value       = aws_opensearch_domain.domain.endpoint
}

output "domain_dashboard_endpoint" {
  description = "Domain Dashboard endpoint"
  value       = aws_opensearch_domain.domain.dashboard_endpoint
}

output "domain_all" {
  description = "Map of all Domain attributes"
  value       = aws_opensearch_domain.domain
}