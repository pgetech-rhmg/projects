output "sfn_activity_id" {
  description = "The Amazon Resource Name (ARN) that identifies the created activity."
  value       = module.activity.sfn_activity_id
}

output "sfn_activity_name" {
  description = "The name of the activity."
  value       = module.activity.sfn_activity_name
}