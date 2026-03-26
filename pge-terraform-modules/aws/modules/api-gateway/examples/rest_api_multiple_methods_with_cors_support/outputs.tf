# Output for api_gateway_rest_api
output "api_gateway_rest_api_id" {
  value       = module.api_gateway_resource.api_gateway_rest_api_id
  description = "The ID of the REST API"
}

output "api_gateway_rest_api_root_resource_id" {
  value       = module.api_gateway_resource.api_gateway_rest_api_root_resource_id
  description = "The Resource ID of the REST API's root"
}

output "api_gateway_rest_api_created_date" {
  value       = module.api_gateway_resource.api_gateway_rest_api_created_date
  description = "The creation date of the REST API"
}

output "api_gateway_rest_api_execution_arn" {
  value       = module.api_gateway_resource.api_gateway_rest_api_execution_arn
  description = "The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function"
}

output "api_gateway_rest_api_arn" {
  value       = module.api_gateway_resource.api_gateway_rest_api_arn
  description = "The Amazon Resource Name for API Gateway REST API"
}

output "api_gateway_rest_api_tags_all" {
  value       = module.api_gateway_resource.api_gateway_rest_api_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}