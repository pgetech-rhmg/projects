output "id" {
  description = "The name of the Human Task UI."
  value       = module.human_task_ui.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Human Task UI."
  value       = module.human_task_ui.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.human_task_ui.tags_all
}

output "ui_template" {
  description = "The Liquid template for the worker user interface."
  value       = module.human_task_ui.ui_template
}