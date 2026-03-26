#graphql_api
output "graphql_all" {
  description = "All output for graphql_api_id"
  value       = module.graphql_api[*].id
}

#outputs for datasource
output "datasource_all" {
  description = "All outputs do datatsource."
  value       = module.datasource[*].arn
}


#outputs for domain name 
output "domain_all" {
  description = "Domain name that AppSync provides."
  value       = try(module.appsync_domain_name[0].appsync_domain_name, null)
}


#outputs for domain name api association 
output "domain_name_api_association_id_all" {
  description = "AppSync domain name"
  value       = try(module.appsync_domain_name_api_association[*].domain_name_api_association_id, null)
}

#outputs for function
output "function_all" {
  description = "All output of the Function object."
  value       = module.function[*].function_arn
}

#output for resolver
output "resolver_all" {
  description = "All output of the resolver"
  value       = module.resolver[*].appsync_resolver_arn
}