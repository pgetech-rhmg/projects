# Outputs for Amplify Webhook

output "arn" {
  description = "ARN for the webhook."
  value       = aws_amplify_webhook.amplify_webhook.arn
}

output "url" {
  description = "URL of the webhook."
  value       = aws_amplify_webhook.amplify_webhook.url
}

output "amplify_webhook" {
  description = "A map of aws amplify webhook"
  value       = aws_amplify_webhook.amplify_webhook
}