#Output for glue data catalog encryption settings
output "catalog_encryption_settings_id" {
  description = "The ID of the Data Catalog to set the security configuration for."
  value       = module.glue_data_catalog_encryption_settings.catalog_encryption_settings_id
}