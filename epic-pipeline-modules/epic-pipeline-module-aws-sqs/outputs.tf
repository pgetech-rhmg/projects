output "queue_id" {
  description = "Queue URL (also used as the ID)."
  value       = aws_sqs_queue.this.id
}

output "queue_url" {
  description = "Queue URL."
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "Queue ARN."
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Queue name."
  value       = aws_sqs_queue.this.name
}
