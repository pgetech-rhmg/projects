################################3 outputs of sqs resources ######################################
output "arn" {
  value       = aws_sqs_queue.queue.arn
  description = "The ARN for the created Amazon SQS queue"
}

output "id" {
  value       = aws_sqs_queue.queue.id
  description = "The URL for the created Amazon SQS queue"
}

output "tags_all" {
  value       = aws_sqs_queue.queue.tags_all
  description = "A map of tags assigned to the resource"
}

output "url" {
  value       = aws_sqs_queue.queue.url
  description = "The URL for the created Amazon SQS queue"
}

output "sqs_queue_all" {
  description = "A map of aws sqs queue"
  value       = aws_sqs_queue.queue
}

output "sqs_queue_policy_all" {
  description = "A map of aws sqs queue policy"
  value       = aws_sqs_queue_policy.policy
}