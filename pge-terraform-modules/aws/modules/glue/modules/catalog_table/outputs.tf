output "arn" {
  description = "The ARN of the Glue Table"
  value       = aws_glue_catalog_table.glue_catalog_table.arn
}

output "id" {
  description = "Catalog ID, Database name and of the name table"
  value       = aws_glue_catalog_table.glue_catalog_table.id
}


output "aws_glue_catalog_table" {
  description = "Map of aws_glue_catalog_table object"
  value       = aws_glue_catalog_table.glue_catalog_table
}


output "name" {
  description = "Catalog ID, Database name and of the name table"
  value       = aws_glue_catalog_table.glue_catalog_table.name
}

