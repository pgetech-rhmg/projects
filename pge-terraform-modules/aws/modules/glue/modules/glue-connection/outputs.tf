# Outputs for glue_connection

output "glue_connection_id" {
  description = "Catalog ID and name of the connection"
  value       = aws_glue_connection.glue_connection.id
}

output "glue_connection_arn" {
  description = "The ARN of the Glue Connection."
  value       = aws_glue_connection.glue_connection.arn
}

output "glue_connection_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = aws_glue_connection.glue_connection.tags_all
}

output "aws_glue_connection" {
  description = "A map of aws_glue_connection object"
  value       = aws_glue_connection.glue_connection
}
