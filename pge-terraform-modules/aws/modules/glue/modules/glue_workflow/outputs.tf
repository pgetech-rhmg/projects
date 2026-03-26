#outputs for workflow
output "glue_workflow_id" {
  description = "Workflow name"
  value       = aws_glue_workflow.glue_workflow.id
}

output "glue_workflow_arn" {
  description = "Amazon Resource Name (ARN) of Glue Workflow"
  value       = aws_glue_workflow.glue_workflow.arn
}

output "glue_workflow_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_glue_workflow.glue_workflow.tags_all
}

output "aws_glue_workflow" {
  description = "A map of aws_glue_workflow object."
  value       = aws_glue_workflow.glue_workflow
}