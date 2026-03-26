output "arn" {
  description = "The ARN of the appsync datasource."
  value       = aws_appsync_datasource.datasource.arn
}

output "name" {
  description = "User-supplied name for the data source."
  value       = aws_appsync_datasource.datasource.name
}

output "aws_appsync_datasource_all" {
  description = "Map of tws_appsync_datasource object."
  value       = aws_appsync_datasource.datasource
}