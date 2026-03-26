output "event_subscription_arn" {
  value       = aws_dms_event_subscription.eventone.arn
  description = "Amazon Resource Name (ARN) of the DMS Event Subscription."
}

output "dms_event_subscription_all" {
  value       = aws_dms_event_subscription.eventone
  description = "A map of aws dms event subscription"

}