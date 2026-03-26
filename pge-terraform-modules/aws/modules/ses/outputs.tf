output "ses_configuration_set_arn" {
  value       = resource.aws_ses_configuration_set.default.arn
  description = "SES configuration set ARN."
}

output "ses_configuration_set_id" {
  value       = resource.aws_ses_configuration_set.default.id
  description = "SES configuration set name. "
}

output "last_fresh_start" {
  value       = resource.aws_ses_configuration_set.default.last_fresh_start
  description = "Date and time at which the reputation metrics for the configuration set were last reset. Resetting these metrics is known as a fresh start."
}

output "ses_configuration_set_all" {
  value       = resource.aws_ses_configuration_set.default
  description = "Map of SES configuration output"
}

