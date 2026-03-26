/*
 * # AWS SNS Subscription module
 * Terraform module which creates SAF2.0 SNS Subscription in AWS
*/

#
#  Filename    : modules/sns/modules/sns_subscription/main.tf
#  Date        : 15 August 2022
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : AWS SNS Subscription terraform module creates a sns subscription
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}



resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  count                 = length(var.endpoint)
  endpoint              = var.endpoint[count.index]
  protocol              = var.protocol
  subscription_role_arn = var.subscription_role_arn
  topic_arn             = var.topic_arn

  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes
  delivery_policy                 = var.delivery_policy
  endpoint_auto_confirms          = var.endpoint_auto_confirms
  filter_policy                   = var.filter_policy
  raw_message_delivery            = var.raw_message_delivery
  redrive_policy                  = var.redrive_policy
}
