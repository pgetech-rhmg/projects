# Subscribe sns to email
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.sns_subscription_email_address_list)
  topic_arn = var.sns_topic
  protocol  = "email"
  endpoint  = element(var.sns_subscription_email_address_list, count.index)
}
