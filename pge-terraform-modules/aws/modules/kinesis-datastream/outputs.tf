output "id" {
  description = "The unique Stream id"
  value       = aws_kinesis_stream.kinesis_stream.id
}

output "name" {
  description = "The unique Stream name"
  value       = aws_kinesis_stream.kinesis_stream.name
}

output "shard_count" {
  description = "The count of Shards for this Stream"
  value       = aws_kinesis_stream.kinesis_stream.shard_count
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the Stream"
  value       = aws_kinesis_stream.kinesis_stream.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_kinesis_stream.kinesis_stream.tags_all
}

output "kinesis_stream_all" {
  description = "A map of kinesis_stream attributes"
  value       = aws_kinesis_stream.kinesis_stream
}