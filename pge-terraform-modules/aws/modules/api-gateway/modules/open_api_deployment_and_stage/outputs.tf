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

#Output for api_gateway_client_certificate
output "api_gateway_client_certificate_id" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].id : null
  description = "The identifier of the client certificate"
}

output "api_gateway_client_certificate_created_date" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].created_date : null
  description = "The date when the client certificate was created"
}

output "api_gateway_client_certificate_expiration_date" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].expiration_date : null
  description = "The date when the client certificate will expire."
}

output "api_gateway_client_certificate_pem_encoded_certificate" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].pem_encoded_certificate : null
  description = "The identifier of the client certificate"
}

output "api_gateway_client_certificate_arn" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].arn : null
  description = "The Amazon Resource Name (ARN) of the client certificate"
}

output "api_gateway_client_certificate_tags_all" {
  value       = var.api_gateway_client_certificate_create ? aws_api_gateway_client_certificate.api_gateway_client_certificate[0].tags_all : null
  description = "A map of tags assigned to the resource"
}

# Output for api_gateway_vpc_link
output "api_gateway_vpc_link_id" {
  value       = var.vpc_link_name != null ? aws_api_gateway_vpc_link.api_gateway_vpc_link[0].id : null
  description = "The identifier of the VpcLink"
}

output "api_gateway_vpc_link_tags_all" {
  value       = var.vpc_link_name != null ? aws_api_gateway_vpc_link.api_gateway_vpc_link[0].tags_all : null
  description = "A map of tags assigned to the resource"
}

# Output for api_gateway_documentation_part
output "api_gateway_documentation_part_id" {
  value       = var.documentation_part_properties != null ? aws_api_gateway_documentation_part.api_gateway_documentation_part[0].id : null
  description = "The unique ID of the Documentation Part"
}

# Output for api_gateway_account
output "api_gateway_account_throttle_settings" {
  value       = var.api_gateway_account_create ? aws_api_gateway_account.api_gateway_account[0].throttle_settings : null
  description = "Account-Level throttle settings."
}

output "aws_api_gateway_deployment_all" {
  value       = aws_api_gateway_deployment.api_gateway_deployment
  description = "A map of all attributes"
}
