#outputs for glue_partition_index
output "partition_index_id" {
  description = "Catalog ID, Database name,table name, and index name."
  value       = aws_glue_partition_index.glue_partition_index.id
}


output "aws_glue_partition_index" {
  description = "The map of aws_glue_partition_index."
  value       = aws_glue_partition_index.glue_partition_index
}