# Outputs for dynamodb table

output "dynamodb_table" {
  description = "Object of the DynamoDB table"
  value       = aws_dynamodb_table.dynamodb_table
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.dynamodb_table.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.dynamodb_table.id
}

output "stream_arn" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  value       = aws_dynamodb_table.dynamodb_table.stream_arn
}

output "stream_label" {
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true."
  value       = aws_dynamodb_table.dynamodb_table.stream_label
}

output "replica_arn" {
  description = "ARN of the replica"
  value       = var.stream_enabled ? aws_dynamodb_table.dynamodb_table.replica[*].arn : ["Stream and Replica are not enabled"]
}

output "replica_stream_arn" {
  description = "ARN of the replica Table Stream. Only available when stream_enabled = true"
  value       = var.stream_enabled ? aws_dynamodb_table.dynamodb_table.replica[*].stream_arn : ["Stream and Replica are not enabled"]
}

output "replica_stream_label" {
  description = "Timestamp, in ISO 8601 format, for the replica stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true."
  value       = var.stream_enabled ? aws_dynamodb_table.dynamodb_table.replica[*].stream_label : ["Stream and Replica are not enabled"]
}