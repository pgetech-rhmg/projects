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

# Output for api_gateway_model
output "api_gateway_model_id" {
  value       = var.model_content_type != null ? aws_api_gateway_model.api_gateway_model[0].id : null
  description = "The ID of the model"
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

output "aws_api_gateway_rest_api_all" {
  value       = aws_api_gateway_rest_api.api_gateway_rest_api
  description = "A map of all attributes"
}