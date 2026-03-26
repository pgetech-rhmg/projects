# Output for api_gateway_usage_plan
output "api_gateway_usage_plan_id" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.id
  description = "The ID of the API resource"
}

output "api_gateway_usage_plan_name" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.name
  description = "The name of the usage plan"
}

output "api_gateway_usage_plan_description" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.description
  description = "The description of a usage plan"
}

output "api_gateway_usage_plan_api_stages" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.api_stages
  description = "The associated API stages of the usage plan"
}

output "api_gateway_usage_plan_quota_settings" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.quota_settings
  description = "The quota of the usage plan"
}

output "api_gateway_usage_plan_throttle_settings" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.throttle_settings
  description = "The throttling limits of the usage plan"
}

output "api_gateway_usage_plan_product_code" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.product_code
  description = "The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace"
}

output "api_gateway_usage_plan_arn" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.arn
  description = "The Amazon Resource Name (ARN) of usage_plan version"
}

output "api_gateway_usage_plan_tags_all" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}

#api_gateway_usage_plan_key
output "api_gateway_usage_plan_key_id" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].id : null
  description = "The Id of a usage plan key"
}

output "api_gateway_usage_plan_key_key_id" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].key_id : null
  description = "The identifier of the API gateway key resource"
}

output "api_gateway_usage_plan_key_key_type" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].key_type : null
  description = "The type of a usage plan key. Currently, the valid key type is API_KEY"
}

output "api_gateway_usage_plan_key_usage_plan_id" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].usage_plan_id : null
  description = "The ID of the API resource"
}

output "api_gateway_usage_plan_key_name" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].name : null
  description = "The name of a usage plan key"
}

output "api_gateway_usage_plan_key_value" {
  value       = var.usage_plan_key_type != null ? aws_api_gateway_usage_plan_key.api_gateway_usage_plan_key[0].value : null
  description = "The value of a usage plan key"
}

output "api_gateway_usage_plan_all" {
  value       = aws_api_gateway_usage_plan.api_gateway_usage_plan
  description = "A map of all attributes"
}
