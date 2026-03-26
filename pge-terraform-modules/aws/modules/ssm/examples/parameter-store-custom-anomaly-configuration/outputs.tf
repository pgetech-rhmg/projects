output "custom_email_address_name" {
  description = "Name of the ssm parameter."
  value       = module.custom_email_address.name
}

output "custom_email_address_version" {
  description = "Version of the ssm parameter."
  value       = module.custom_email_address.version
}

output "custom_email_address_arn" {
  description = "ARN of the ssm parameter."
  value       = module.custom_email_address.arn
}

output "custom_email_address_type" {
  description = "Type of the ssm parameter."
  value       = module.custom_email_address.type
}

output "custom_threshold_name" {
  description = "Name of the ssm parameter."
  value       = module.custom_threshold.name
}

output "custom_threshold_version" {
  description = "Version of the ssm parameter."
  value       = module.custom_threshold.version
}

output "custom_threshold_arn" {
  description = "ARN of the ssm parameter."
  value       = module.custom_threshold.arn
}

output "custom_threshold_type" {
  description = "Type of the ssm parameter."
  value       = module.custom_threshold.type
}
