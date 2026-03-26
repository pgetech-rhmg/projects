#Outputs for glue registry
output "glue_registry_id" {
  description = "Amazon Resource Name (ARN) of Glue Registry."
  value       = aws_glue_registry.glue_registry.id
}

output "glue_registry_arn" {
  description = "Amazon Resource Name (ARN) of Glue Registry."
  value       = aws_glue_registry.glue_registry.arn
}

output "glue_registry_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_glue_registry.glue_registry.tags_all
}


output "aws_glue_registry" {
  description = "A map of aws_glue_registry object."
  value       = aws_glue_registry.glue_registry
}