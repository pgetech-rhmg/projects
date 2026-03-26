output "this_sqs_queue_id" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.sqs.id
}

output "this_sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.arn
}

output "tags_all" {
  value       = module.sqs.tags_all
  description = " A map of tags assigned to the resource"
}

output "url" {
  value       = module.sqs.url
  description = "The URL for the created Amazon SQS queue"
}