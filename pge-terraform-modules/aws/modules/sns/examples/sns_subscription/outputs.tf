output "sns_topic_id" {
  description = "The id of the SNS topic"
  value       = module.sns_topic.sns_topic_id
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = module.sns_topic.sns_topic_arn
}

output "sns_topic_owner" {
  description = "The AWS Account ID of the SNS topic owner"
  value       = module.sns_topic.sns_topic_owner
}

output "sns_topic_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider "
  value       = module.sns_topic.sns_topic_tags_all
}

#outputs for sns_subscription
output "sns_subscription_arn" {
  value       = module.sns_topic_subscription[*].sns_subscription_arn
  description = "ARN of the subscription"
}

output "sns_subscription_confirmation_was_authenticated" {
  value       = module.sns_topic_subscription[*].sns_subscription_confirmation_was_authenticated
  description = "Whether the subscription confirmation request was authenticated"
}

output "sns_subscription_owner_id" {
  value       = module.sns_topic_subscription[*].sns_subscription_owner_id
  description = "AWS account ID of the subscription's owner"
}

output "sns_subscription_pending_confirmation" {
  value       = module.sns_topic_subscription[*].sns_subscription_pending_confirmation
  description = "Whether the subscription has not been confirmed"
}

