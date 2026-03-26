# Output for api_gateway_rest_api
output "api_gateway_rest_api_id" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.id
  description = "The ID of the REST API"
}

output "api_gateway_rest_api_root_resource_id" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  description = "The Resource ID of the REST API's root"
}

output "api_gateway_rest_api_created_date" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.created_date
  description = "The creation date of the REST API"
}

output "api_gateway_rest_api_execution_arn" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn
  description = "The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function"
}

output "api_gateway_rest_api_arn" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.arn
  description = "The Amazon Resource Name for API Gateway REST API"
}

output "api_gateway_rest_api_tags_all" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

output "aws_api_gateway_rest_api_all" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api
  description = "A map of all attributes"
}
