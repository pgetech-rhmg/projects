output "ses_configuration_set_arn" {
  value       = module.ses.ses_configuration_set_arn
  description = "SES configuration set ARN."
}

output "ses_configuration_set_id" {
  value       = module.ses.ses_configuration_set_id
  description = "SES configuration set name. "
}

output "last_fresh_start" {
  value       = module.ses.last_fresh_start
  description = "Date and time at which the reputation metrics for the configuration set were last reset. Resetting these metrics is known as a fresh start."
}
