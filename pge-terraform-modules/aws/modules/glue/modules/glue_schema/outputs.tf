#Outputs for glue schema

output "glue_schema_arn" {
  description = "Amazon Resource Name (ARN) of the schema."
  value       = aws_glue_schema.glue_schema.arn
}

output "glue_schema_id" {
  description = "Amazon Resource Name (ARN) of the schema."
  value       = aws_glue_schema.glue_schema.id
}

output "glue_registry_name" {
  description = " The name of the Glue Registry."
  value       = aws_glue_schema.glue_schema.schema_name
}

output "glue_latest_schema_version" {
  description = "The latest version of the schema associated with the returned schema definition."
  value       = aws_glue_schema.glue_schema.latest_schema_version
}

output "glue_next_schema_version" {
  description = "The next version of the schema associated with the returned schema definition."
  value       = aws_glue_schema.glue_schema.next_schema_version
}

output "glue_schema_checkpoint" {
  description = "The version number of the checkpoint (the last time the compatibility mode was changed)."
  value       = aws_glue_schema.glue_schema.schema_checkpoint
}

output "glue_schema_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_glue_schema.glue_schema.tags_all
}

output "aws_glue_schema" {
  description = "A map of aws_glue_schema object."
  value       = aws_glue_schema.glue_schema
}