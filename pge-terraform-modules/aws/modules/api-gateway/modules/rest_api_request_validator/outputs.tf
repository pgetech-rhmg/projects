# Output for api_gateway_request_validator
output "api_gateway_request_validator_id" {
  value       = aws_api_gateway_request_validator.api_gateway_request_validator.id
  description = "The unique ID of the request validator"
}