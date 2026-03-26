output "sns_topic_id" {
  value       = resource.aws_sns_topic.sns-topic.id
  description = "The id of the SNS topic"
}

output "sns_topic_arn" {
  value       = resource.aws_sns_topic.sns-topic.arn
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
}

output "sns_topic_owner" {
  value       = resource.aws_sns_topic.sns-topic.owner
  description = "The AWS Account ID of the SNS topic owner"
}

output "sns_topic_tags_all" {
  value       = resource.aws_sns_topic.sns-topic.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider"
}

output "sns_topic_all" {
  description = "A map of aws sns topic"
  value       = aws_sns_topic.sns-topic
}

output "sns_topic_policy_all" {
  description = "A map of aws sns topic policy"
  value       = aws_sns_topic_policy.sns
}