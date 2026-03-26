output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Flow Definition."
  value       = aws_sagemaker_flow_definition.flow_definition.arn
}

output "id" {
  description = "The name of the Flow Definition."
  value       = aws_sagemaker_flow_definition.flow_definition.id
}

output "tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_sagemaker_flow_definition.flow_definition.tags_all
}

output "sagemaker_flow_definition_all" {
  description = "A map of aws sagemaker flow definition"
  value       = aws_sagemaker_flow_definition.flow_definition
}