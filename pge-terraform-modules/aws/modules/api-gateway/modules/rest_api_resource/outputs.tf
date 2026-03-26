# Output for api_gateway_resource
output "api_gateway_resource_id" {
  value       = aws_api_gateway_resource.api_gateway_resource.id
  description = "The ID of the API Gateway Resource"
}

output "api_gateway_resource_path" {
  value       = aws_api_gateway_resource.api_gateway_resource.path
  description = "The path for API Gateway Resource with including all parent paths"
}