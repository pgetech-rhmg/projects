#Outputs for transfer family workflow
output "transfer_workflow_arn" {
  description = "The Workflow ARN."
  value       = aws_transfer_workflow.transfer_workflow.arn
}

output "transfer_workflow_id" {
  description = "The Workflow id."
  value       = aws_transfer_workflow.transfer_workflow.id
}

output "transfer_workflow_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_transfer_workflow.transfer_workflow.tags_all
}

output "transfer_workflow_all" {
  description = "Map of transfer_workflow object"
  value       = aws_transfer_workflow.transfer_workflow
}