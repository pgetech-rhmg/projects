# Outputs for Glue Trigger

output "glue_trigger_arn" {
  description = "Amazon Resource Name (ARN) of Glue Trigger"
  value       = aws_glue_trigger.glue_trigger.arn
}

output "glue_trigger_id" {
  description = "Trigger name"
  value       = aws_glue_trigger.glue_trigger.id
}

output "glue_trigger_state" {
  description = "The current state of the trigger."
  value       = aws_glue_trigger.glue_trigger.state
}

output "glue_trigger_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = aws_glue_trigger.glue_trigger.tags_all
}

output "aws_glue_trigger" {
  description = "A map of aws_glue_trigger object"
  value       = aws_glue_trigger.glue_trigger
}