output "arn" {
  description = "ARN of the Glue Catalog Database"
  value       = aws_glue_catalog_database.glue_catalog_database.arn
}

output "id" {
  description = "Catalog ID and name of the database"
  value       = aws_glue_catalog_database.glue_catalog_database.id
}

output "aws_glue_catalog_database" {
  description = "Map of aws_glue_catalog_database object"
  value       = aws_glue_catalog_database.glue_catalog_database
}

output "name" {
  description = "Catalog ID, Database name and of the name table"
  value       = aws_glue_catalog_database.glue_catalog_database.name
}
