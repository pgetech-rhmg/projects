# Output for dynamodb kinesis streaming

output "kinesis_id" {
  description = "The table_name and stream_arn separated by a comma (,)."
  value       = aws_dynamodb_kinesis_streaming_destination.dynamodb_kinesis_streaming_destination.id
}