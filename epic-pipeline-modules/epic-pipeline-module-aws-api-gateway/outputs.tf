output "rest_api_id" {
  description = "REST API ID."
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_arn" {
  description = "REST API ARN."
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "REST API execution ARN (for Lambda permissions)."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "root_resource_id" {
  description = "REST API root resource ID."
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "stage_invoke_url" {
  description = "Stage invoke URL."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "authorizer_id" {
  description = "Authorizer ID (null if no authorizer configured)."
  value       = length(aws_api_gateway_authorizer.this) > 0 ? aws_api_gateway_authorizer.this[0].id : null
}
