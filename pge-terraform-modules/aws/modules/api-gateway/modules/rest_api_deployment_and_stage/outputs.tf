#Output for api_gateway_deployment
output "api_gateway_deployment_id" {
  value       = aws_api_gateway_deployment.api_gateway_deployment.id
  description = "The ID for API Gateway Deployment"
}

output "api_gateway_deployment_created_date" {
  value       = aws_api_gateway_deployment.api_gateway_deployment.created_date
  description = "The creation date of the deployment"
}

# Output for api_gateway_stage
output "api_gateway_stage_arn" {
  value       = aws_api_gateway_stage.api_gateway_stage.arn
  description = "The Amazon Resource Name (ARN) for API Gateway Stage"
}

output "api_gateway_stage_name" {
  value       = aws_api_gateway_stage.api_gateway_stage.stage_name
  description = "The Amazon Resource Name (ARN) for API Gateway Stage"
}

output "api_gateway_stage_id" {
  value       = aws_api_gateway_stage.api_gateway_stage.id
  description = "The ID for API Gateway Stage"
}

output "api_gateway_stage_invoke_url" {
  value       = aws_api_gateway_stage.api_gateway_stage.invoke_url
  description = "The URL to invoke the API pointing to the stage"
}

output "api_gateway_stage_execution_arn" {
  value       = aws_api_gateway_stage.api_gateway_stage.execution_arn
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}

output "api_gateway_stage_tags_all" {
  value       = aws_api_gateway_stage.api_gateway_stage.tags_all
  description = "A map of tags assigned to the resource"
}

output "api_gateway_stage_web_acl_arn" {
  value       = aws_api_gateway_stage.api_gateway_stage.web_acl_arn
  description = "The ARN of the WebAcl associated with the Stage"
}

output "aws_api_gateway_deployment_all" {
  value       = aws_api_gateway_deployment.api_gateway_deployment
  description = "A map of all attributes"
}