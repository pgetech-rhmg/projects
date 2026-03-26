# Output for api_gateway_rest_api
output "api_gateway_rest_api_id" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_id
  description = "The ID of the REST API"
}

output "api_gateway_rest_api_root_resource_id" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_root_resource_id
  description = "The Resource ID of the REST API's root"
}

output "api_gateway_rest_api_created_date" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_created_date
  description = "The creation date of the REST API"
}

output "api_gateway_rest_api_execution_arn" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_execution_arn
  description = "The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function"
}

output "api_gateway_rest_api_arn" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_arn
  description = "The Amazon Resource Name for API Gateway REST API"
}

output "api_gateway_rest_api_tags_all" {
  value       = module.api_gateway_rest_api.api_gateway_rest_api_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

# Output for api_gateway_deployment
output "api_gateway_deployment_id" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_deployment_id
  description = "The ID for API Gateway Deployment"
}

output "api_gateway_deployment_invoke_url" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_deployment_invoke_url
  description = "The URL to invoke the API pointing to the stage"
}

output "api_gateway_deployment_execution_arn" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_deployment_execution_arn
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}

output "api_gateway_deployment_created_date" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_deployment_created_date
  description = "The creation date of the deployment"
}

# Output for api_gateway_stage
output "api_gateway_stage_arn" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_arn
  description = "The Amazon Resource Name (ARN) for API Gateway Stage"
}

output "api_gateway_stage_id" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_id
  description = "The ID for API Gateway Stage"
}

output "api_gateway_stage_invoke_url" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_invoke_url
  description = "The URL to invoke the API pointing to the stage"
}

output "api_gateway_stage_execution_arn" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_execution_arn
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}

output "api_gateway_stage_tags_all" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_tags_all
  description = "A map of tags assigned to the resource"
}

output "api_gateway_stage_web_acl_arn" {
  value       = module.api_gateway_deployment_and_stage.api_gateway_stage_web_acl_arn
  description = "The ARN of the WebAcl associated with the Stage"
}