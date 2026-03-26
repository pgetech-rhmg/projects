# Output for api_gateway_api_key
output "api_gateway_api_key_id" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.id
  description = "The ID for API Gateway API key ID"
}

output "api_gateway_api_key_created_date" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.created_date
  description = "The creation date of the API key"
}

output "api_gateway_api_key_last_updated_date" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.last_updated_date
  description = "The last_updated_date of the API key"
}

output "api_gateway_api_key_value" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.value
  description = "The value of the API key"
}

output "api_gateway_api_key_arn" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.arn
  description = "The Amazon Resource Name (ARN) for API Gateway API Key"
}

output "api_gateway_api_key_tags_all" {
  value       = aws_api_gateway_api_key.api_gateway_api_key.tags_all
  description = "A map of tags assigned to the resource"
}

output "api_gateway_api_key_all" {
  value       = aws_api_gateway_api_key.api_gateway_api_key
  description = "A map of all attributes"
}