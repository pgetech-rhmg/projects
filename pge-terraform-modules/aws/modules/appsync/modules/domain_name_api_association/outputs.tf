# outputs for domain name api association
output "domain_name_api_association_id" {
  description = "Appsync domain name."
  value       = aws_appsync_domain_name_api_association.domain_name_api_association.id
}

output "domain_name_api_association_all" {
  description = "Map of appsync_domain_name_api_association object."
  value       = aws_appsync_domain_name_api_association.domain_name_api_association
}