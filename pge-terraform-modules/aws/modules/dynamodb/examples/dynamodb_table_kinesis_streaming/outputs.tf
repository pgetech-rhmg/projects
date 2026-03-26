# Outputs for dynamo db table

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_id
}

output "stream_arn" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  value       = module.dynamodb_table.stream_arn
}

output "stream_label" {
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true."
  value       = module.dynamodb_table.stream_label
}

# Output for dynamodb kinesis streaming

output "kinesis_id" {
  description = "The table_name and stream_arn separated by a comma (,)."
  value       = module.kinesis_streaming_destination.kinesis_id
}