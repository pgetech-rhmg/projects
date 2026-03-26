#Outputs of flow_definition
output "flow_definition_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Flow Definition."
  value       = module.flow_definition.arn
}

output "flow_definition_id" {
  description = "The name of the Flow Definition."
  value       = module.flow_definition.id
}

output "flow_definition_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.flow_definition.tags_all
}

#Outputs of human_task_ui
output "human_task_ui_id" {
  description = "The name of the Human Task UI."
  value       = module.human_task_ui.id
}

output "human_task_ui_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Human Task UI."
  value       = module.human_task_ui.arn
}

output "human_task_ui_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.human_task_ui.tags_all
}

output "human_task_ui_template" {
  description = "The Liquid template for the worker user interface."
  value       = module.human_task_ui.ui_template
}

#Outputs of s3
output "s3_bucket" {
  description = "Map of S3 object"
  value       = module.s3.s3.bucket
}

output "s3_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.arn
}