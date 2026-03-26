#Output for glue data catalog encryption settings
output "catalog_encryption_settings_id" {
  description = "The ID of the Data Catalog to set the security configuration for."
  value       = aws_glue_data_catalog_encryption_settings.glue_data_catalog_encryption_settings.id
}

output "aws_glue_data_catalog_encryption_settings" {
  description = "The map of aws_glue_data_catalog_encryption_settings."
  value       = aws_glue_data_catalog_encryption_settings.glue_data_catalog_encryption_settings
}