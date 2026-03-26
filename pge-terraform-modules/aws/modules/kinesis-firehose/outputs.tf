#outputs for kinesis-firehose
output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the Stream"
  value       = aws_kinesis_firehose_delivery_stream.kinesis_firehose_delivery_stream.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_kinesis_firehose_delivery_stream.kinesis_firehose_delivery_stream.tags_all
}


output "aws_kinesis_firehose_delivery_stream_all" {
  description = "kinesis_firehose_delivery_stream"
  value       = aws_kinesis_firehose_delivery_stream.kinesis_firehose_delivery_stream
}