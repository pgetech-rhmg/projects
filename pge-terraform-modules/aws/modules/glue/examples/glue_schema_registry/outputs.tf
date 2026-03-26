#Outputs for glue registry
output "glue_registry_id" {
  description = "Amazon Resource Name (ARN) of Glue Registry."
  value       = module.glue_registry.glue_registry_id
}

output "glue_registry_arn" {
  description = "Amazon Resource Name (ARN) of Glue Registry."
  value       = module.glue_registry.glue_registry_arn
}

output "glue_registry_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.glue_registry.glue_registry_tags_all
}

#Outputs for glue Schema
output "glue_schema_arn" {
  description = "Amazon Resource Name (ARN) of the schema."
  value       = module.glue_schema.glue_schema_arn
}

output "glue_schema_id" {
  description = "Amazon Resource Name (ARN) of the schema."
  value       = module.glue_schema.glue_schema_id
}

output "glue_registry_name" {
  description = " The name of the Glue Registry."
  value       = module.glue_schema.glue_registry_name
}

output "glue_latest_schema_version" {
  description = "The latest version of the schema associated with the returned schema definition."
  value       = module.glue_schema.glue_latest_schema_version
}

output "glue_next_schema_version" {
  description = "The next version of the schema associated with the returned schema definition."
  value       = module.glue_schema.glue_next_schema_version
}

output "glue_schema_checkpoint" {
  description = "The version number of the checkpoint (the last time the compatibility mode was changed)."
  value       = module.glue_schema.glue_schema_checkpoint
}

output "glue_schema_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.glue_schema.glue_schema_tags_all
}