# Output for api_gateway_authorizer
output "api_gateway_authorizer_id" {
  value       = aws_api_gateway_authorizer.api_gateway_authorizer.id
  description = "The ID for API Gateway Authorizer"
}