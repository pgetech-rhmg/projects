#outputs for workflow
output "glue_workflow_id" {
  description = "Workflow name"
  value       = module.glue_workflow.glue_workflow_id
}

output "glue_workflow_arn" {
  description = "Amazon Resource Name (ARN) of Glue Workflow"
  value       = module.glue_workflow.glue_workflow_arn
}

output "glue_workflow_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.glue_workflow.glue_workflow_tags_all
}