output "scheduled_action" {
  description = "The Redshift Scheduled Action name."
  value       = try(aws_redshift_scheduled_action.scheduled_action[0].id, "")
}

output "aws_redshift_scheduled_action_all" {
  description = "A map of aws redshift scheduled action resource attributes references"
  value       = aws_redshift_scheduled_action.scheduled_action

}