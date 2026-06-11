output "configuration_set_name" {
  description = "SES configuration set name."
  value       = aws_ses_configuration_set.this.name
}

output "configuration_set_arn" {
  description = "SES configuration set ARN."
  value       = aws_ses_configuration_set.this.arn
}

output "event_destination_name" {
  description = "Name of the SES event destination if managed by this module."
  value       = local.manage_event_destination ? aws_ses_event_destination.this[0].name : null
}
