#Outputs for event subscription
output "event_subscription" {
  description = "The entire output of resource"
  value       = aws_docdb_event_subscription.docdb_event_subscription
}

output "event_subscription_id" {
  description = "The name of the DocDB event notification subscription."
  value       = aws_docdb_event_subscription.docdb_event_subscription.id
}

output "event_subscription_arn" {
  description = "The Amazon Resource Name of the DocDB event notification subscription."
  value       = aws_docdb_event_subscription.docdb_event_subscription.arn
}

output "event_subscription_customer_aws_id" {
  description = "The AWS customer account associated with the DocDB event notification subscription."
  value       = aws_docdb_event_subscription.docdb_event_subscription.customer_aws_id
}

output "event_subscription_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_docdb_event_subscription.docdb_event_subscription.tags_all
}