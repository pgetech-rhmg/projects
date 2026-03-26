output "event_source_mapping_function_arn" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.function_arn
  description = "The the ARN of the Lambda function the event source mapping is sending events to"
}

output "event_source_mapping_last_modified" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.last_modified
  description = "The date this resource was last modified"
}

output "event_source_mapping_last_processing_result" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.last_processing_result
  description = "The result of the last AWS Lambda invocation of your Lambda function"
}

output "event_source_mapping_last_state" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.state
  description = "The state of the event source mapping"
}

output "event_source_mapping_state_transition_reason" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.state_transition_reason
  description = "The reason the event source mapping is in its current state"
}

output "event_source_mapping_uuid" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping.uuid
  description = "The UUID of the created event source mapping"
}

output "event_source_mapping_all" {
  value       = aws_lambda_event_source_mapping.kinesis_event_source_mapping
  description = "Map of all object"
}