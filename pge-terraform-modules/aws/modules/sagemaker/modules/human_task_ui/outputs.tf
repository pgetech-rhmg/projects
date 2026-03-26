output "id" {
  description = "The name of the Human Task UI."
  value       = aws_sagemaker_human_task_ui.human_task_ui.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Human Task UI."
  value       = aws_sagemaker_human_task_ui.human_task_ui.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_human_task_ui.human_task_ui.tags_all
}

output "ui_template" {
  description = "The Liquid template for the worker user interface."
  value       = aws_sagemaker_human_task_ui.human_task_ui.ui_template
}

output "sagemaker_human_task_ui_all" {
  description = "A map of aws sagemaker human task ui"
  value       = aws_sagemaker_human_task_ui.human_task_ui
}