#outputs for sns_subscription
output "sns_subscription_arn" {
  value       = resource.aws_sns_topic_subscription.sns_topic_subscription[*].arn
  description = "ARN of the subscription"
}

output "sns_subscription_confirmation_was_authenticated" {
  value       = resource.aws_sns_topic_subscription.sns_topic_subscription[*].confirmation_was_authenticated
  description = "Whether the subscription confirmation request was authenticated"
}

output "sns_subscription_owner_id" {
  value       = resource.aws_sns_topic_subscription.sns_topic_subscription[*].owner_id
  description = "AWS account ID of the subscription's owner"
}

output "sns_subscription_pending_confirmation" {
  value       = resource.aws_sns_topic_subscription.sns_topic_subscription[*].pending_confirmation
  description = "Whether the subscription has not been confirmed"
}

output "sns_topic_subscription_all" {
  description = "A map of aws sns topic subscription"
  value       = aws_sns_topic_subscription.sns_topic_subscription

}