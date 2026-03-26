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
