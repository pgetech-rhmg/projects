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

# Output for api_gateway_resource
output "api_gateway_resource_id" {
  value       = module.api_resource.api_gateway_resource_id
  description = "The ID of the API Gateway Resource"
}

output "api_gateway_resource_path" {
  value       = module.api_resource.api_gateway_resource_path
  description = "The path for API Gateway Resource with including all parent paths"
}

# Output for api_gateway_model
output "api_gateway_model_id" {
  value       = module.api_gateway_resource.api_gateway_model_id
  description = "The ID of the model"
}

# Output for api_gateway_deployment
output "api_gateway_deployment_id" {
  value       = module.api_gateway_stage.api_gateway_deployment_id
  description = "The ID for API Gateway Deployment"
}

# output "api_gateway_deployment_invoke_url" {
#   value       = module.api_gateway_stage.api_gateway_deployment_invoke_url
#   description = "The URL to invoke the API pointing to the stage"
# }

# output "api_gateway_deployment_execution_arn" {
#   value       = module.api_gateway_stage.api_gateway_deployment_execution_arn
#   description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
# }

output "api_gateway_deployment_created_date" {
  value       = module.api_gateway_stage.api_gateway_deployment_created_date
  description = "The creation date of the deployment"
}

# Output for api_gateway_stage
output "api_gateway_stage_arn" {
  value       = module.api_gateway_stage.api_gateway_stage_arn
  description = "The Amazon Resource Name (ARN) for API Gateway Stage"
}

output "api_gateway_stage_id" {
  value       = module.api_gateway_stage.api_gateway_stage_id
  description = "The ID for API Gateway Stage"
}

output "api_gateway_stage_invoke_url" {
  value       = module.api_gateway_stage.api_gateway_stage_invoke_url
  description = "The URL to invoke the API pointing to the stage"
}

output "api_gateway_stage_execution_arn" {
  value       = module.api_gateway_stage.api_gateway_stage_execution_arn
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}

output "api_gateway_stage_tags_all" {
  value       = module.api_gateway_stage.api_gateway_stage_tags_all
  description = "A map of tags assigned to the resource"
}

output "api_gateway_stage_web_acl_arn" {
  value       = module.api_gateway_stage.api_gateway_stage_web_acl_arn
  description = "The ARN of the WebAcl associated with the Stage"
}

# Output for api_gateway_request_validator
output "api_gateway_request_validator_id" {
  value       = module.api_gateway_request_validator.api_gateway_request_validator_id
  description = "The unique ID of the request validator"
}

#Output for api_gateway_client_certificate
output "api_gateway_client_certificate_id" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_id
  description = "The identifier of the client certificate"
}

output "api_gateway_client_certificate_created_date" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_created_date
  description = "The date when the client certificate was created"
}

output "api_gateway_client_certificate_expiration_date" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_expiration_date
  description = "The date when the client certificate will expire."
}

output "api_gateway_client_certificate_pem_encoded_certificate" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_pem_encoded_certificate
  description = "The identifier of the client certificate"
}

output "api_gateway_client_certificate_arn" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_arn
  description = "The Amazon Resource Name (ARN) of the client certificate"
}

output "api_gateway_client_certificate_tags_all" {
  value       = module.api_gateway_resource.api_gateway_client_certificate_tags_all
  description = "A map of tags assigned to the resource"
}

# Output for api_gateway_usage_plan
output "api_gateway_usage_plan_id" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_id
  description = "The ID of the API resource"
}

output "api_gateway_usage_plan_name" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_name
  description = "The name of the usage plan"
}

output "api_gateway_usage_plan_description" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_description
  description = "The description of a usage plan"
}

output "api_gateway_usage_plan_api_stages" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_api_stages
  description = "The associated API stages of the usage plan"
}

output "api_gateway_usage_plan_quota_settings" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_quota_settings
  description = "The quota of the usage plan"
}

output "api_gateway_usage_plan_throttle_settings" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_throttle_settings
  description = "The throttling limits of the usage plan"
}

output "api_gateway_usage_plan_product_code" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_product_code
  description = "The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace"
}

output "api_gateway_usage_plan_arn" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_arn
  description = "The Amazon Resource Name (ARN) of usage_plan version"
}

output "api_gateway_usage_plan_tags_all" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}

#api_gateway_usage_plan_key
output "api_gateway_usage_plan_key_id" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_id
  description = "The Id of a usage plan key"
}

output "api_gateway_usage_plan_key_key_id" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_key_id
  description = "The identifier of the API gateway key resource"
}

output "api_gateway_usage_plan_key_key_type" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_key_type
  description = "The type of a usage plan key. Currently, the valid key type is API_KEY"
}

output "api_gateway_usage_plan_key_usage_plan_id" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_usage_plan_id
  description = "The ID of the API resource"
}

output "api_gateway_usage_plan_key_name" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_name
  description = "The name of a usage plan key"
}

output "api_gateway_usage_plan_key_value" {
  value       = module.api_gateway_usage_plan.api_gateway_usage_plan_key_value
  description = "The value of a usage plan key"
}

# Output for api_gateway_documentation_part
output "api_gateway_documentation_part_id" {
  value       = module.api_gateway_resource.api_gateway_documentation_part_id
  description = "The unique ID of the Documentation Part"
}

# Output for api_gateway_vpc_link
output "api_gateway_vpc_link_id" {
  value       = module.api_gateway_resource.api_gateway_vpc_link_id
  description = "The identifier of the VpcLink"
}

output "api_gateway_vpc_link_tags_all" {
  value       = module.api_gateway_resource.api_gateway_vpc_link_tags_all
  description = "A map of tags assigned to the resource"
}