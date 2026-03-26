#Outputs for glue ml transform
output "arn" {
  description = "Amazon Resource Name (ARN) of Glue ML Transform."
  value       = module.glue_ml_transform.arn
}

output "id" {
  description = "Glue ML Transform ID."
  value       = module.glue_ml_transform.id
}

output "label_count" {
  description = "The number of labels available for this transform."
  value       = module.glue_ml_transform.label_count
}

output "schema" {
  description = "The object that represents the schema that this transform accepts."
  value       = module.glue_ml_transform.schema
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.glue_ml_transform.tags_all
}