output "catalog_database_arn" {
  description = "ARN of the Glue Catalog Database"
  value       = module.catalog_database.arn
}

output "catalog_database_id" {
  description = "Catalog ID and name of the database"
  value       = module.catalog_database.id
}

output "catalog_table_arn" {
  description = "The ARN of the Glue Table"
  value       = module.catalog_table.arn
}

output "catalog_table_id" {
  description = "Catalog ID, Database name and of the name table"
  value       = module.catalog_table.id
}

output "glue_partition_id" {
  description = "partition id."
  value       = module.partition.glue_partition_id
}

output "glue_partition_creation_time" {
  description = " The time at which the partition was created."
  value       = module.partition.glue_partition_creation_time
}

output "glue_partition_last_analyzed_time" {
  description = " The last time at which column statistics were computed for this partition."
  value       = module.partition.glue_partition_last_analyzed_time
}

output "glue_partion_last_accessed_time" {
  description = " The last time at which the partition was accessed."
  value       = module.partition.glue_partion_last_accessed_time
}

output "partition_index_id" {
  description = "Catalog ID, Database name,table name, and index name."
  value       = module.glue_partition_index.partition_index_id
}
