output "database_name" {
  description = "Name of the AWS Glue database created or referenced by this module."
  value       = aws_glue_catalog_database.this.name
}

output "table_name" {
  description = "Name of the AWS Glue table created or referenced within the database."
  value       = aws_glue_catalog_table.this.name
}