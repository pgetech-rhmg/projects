output "id" {
  description = "The unique Stream id"
  value       = module.kinesis_stream.id
}

output "name" {
  description = "The unique Stream name"
  value       = module.kinesis_stream.name
}

output "shard_count" {
  description = "The count of Shards for this Stream"
  value       = module.kinesis_stream.shard_count
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the Stream"
  value       = module.kinesis_stream.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.kinesis_stream.tags_all
}

# outputs for kinesis stream consumer
output "stream_consumer_arn" {
  description = "Amazon Resource Name (ARN) of the stream consumer."
  value       = module.kinesis_stream_consumer.arn
}

output "stream_consumer_creation_timestamp" {
  description = "Approximate timestamp in RFC3339 format of when the stream consumer was created."
  value       = module.kinesis_stream_consumer.creation_timestamp
}

output "stream_consumer_id" {
  description = "Amazon Resource Name (ARN) of the stream consumer."
  value       = module.kinesis_stream_consumer.id
}