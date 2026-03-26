#outputs for kinesis-firehose
output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the Stream"
  value       = module.extended_s3_firehose.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.extended_s3_firehose.tags_all
}