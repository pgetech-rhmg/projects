output "redshift_event_subscription_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift event notification subscription"
  value       = aws_redshift_event_subscription.redshift_event_subscription.arn
}

output "redshift_event_subscription_id" {
  description = "The name of the Redshift event notification subscription"
  value       = aws_redshift_event_subscription.redshift_event_subscription.id
}

output "redshift_event_subscription_customer_aws_id" {
  description = "The AWS customer account associated with the Redshift event notification subscription"
  value       = aws_redshift_event_subscription.redshift_event_subscription.customer_aws_id
}

output "redshift_event_subscription_tags_all" {
  description = " A map of tags assigned to the resource, including those inherited from the provider."
  value       = aws_redshift_event_subscription.redshift_event_subscription.tags_all
}

output "aws_redshift_event_subscription_all" {
  description = "A map of aws redshift event subscription attributes references"
  value       = aws_redshift_event_subscription.redshift_event_subscription

}