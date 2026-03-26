# Outputs for dynamodb table in 'us-west-2'

output "dynamodb_table_arn_us_west_2" {
  description = "ARN of the DynamoDB table."
  value       = module.dynamodb_table_us_west_2.dynamodb_table_arn
}

output "dynamodb_table_id_us_west_2" {
  description = "ID of the DynamoDB table."
  value       = module.dynamodb_table_us_west_2.dynamodb_table_id
}

output "stream_arn_us_west_2" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true."
  value       = module.dynamodb_table_us_west_2.stream_arn
}

output "stream_label_us_west_2" {
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true."
  value       = module.dynamodb_table_us_west_2.stream_label
}
