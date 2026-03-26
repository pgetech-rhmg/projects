output "domain_name_id" {
  description = "The name of the domain."
  value       = aws_appsync_domain_name.domain_name.id
}

output "appsync_domain_name" {
  description = "Domain name that AppSync provides."
  value       = aws_appsync_domain_name.domain_name.appsync_domain_name
}

output "domain_name_hosted_zone_id" {
  description = "ID of your Amazon Route 53 hosted zone."
  value       = aws_appsync_domain_name.domain_name.hosted_zone_id
}

output "aws_appsync_domain_name_all" {
  description = "Map of aws_appsync_domain_name object."
  value       = aws_appsync_domain_name.domain_name
}