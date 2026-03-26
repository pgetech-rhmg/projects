output "sfn_activity_id" {
  description = "The Amazon Resource Name (ARN) that identifies the created activity."
  value       = aws_sfn_activity.sfn_activity.id
}

output "sfn_activity_name" {
  description = "The name of the activity."
  value       = aws_sfn_activity.sfn_activity.name
}

output "sfn_activity_creation_date" {
  description = "The date the activity was created."
  value       = aws_sfn_activity.sfn_activity.creation_date
}

output "sfn_activity_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_sfn_activity.sfn_activity.id
}

output "sfn_activity_all" {
  description = "A map of aws sfn activity"
  value       = aws_sfn_activity.sfn_activity
}