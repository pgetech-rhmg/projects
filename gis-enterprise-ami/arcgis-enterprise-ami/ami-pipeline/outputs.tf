output "assets_bucket_id" {
  description = "Name of the S3 bucket storing pipeline assets"
  value       = module.assets_s3.id
}

output "pipeline_artifacts_bucket_id" {
  description = "Name of the S3 bucket used as CodePipeline artifact store"
  value       = module.pipeline_artifacts_s3.id
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.ami_factory.arn
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.ami_factory.name
}

output "pipeline_notifications_topic_arn" {
  description = "ARN of the SNS topic for pipeline notifications"
  value       = aws_sns_topic.pipeline_notifications.arn
}

output "golden_ami_event_rule_arn" {
  description = "ARN of the EventBridge rule that triggers on golden AMI updates"
  value       = aws_cloudwatch_event_rule.golden_ami_updated.arn
}

output "ami_published_event_rule_arn" {
  description = "ARN of the EventBridge rule that notifies on AMI publication"
  value       = aws_cloudwatch_event_rule.ami_published.arn
}
