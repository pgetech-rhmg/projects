/*
 * # AWS Amplify Webhook module.
 * Terraform module which creates SAF2.0 Amplify Webhook in AWS.
*/

#
#  Filename    : aws/modules/amplify/modules/amplify_webhook/main.tf
#  Date        : 4 October 2022
#  Author      : TCS
#  Description : Amplify Webhook Creation
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

# Module      : Creation of Amplify Webhook
# Description : This terraform module creates an Amplify Webhook.

resource "aws_amplify_webhook" "amplify_webhook" {

  app_id      = var.app_id
  branch_name = var.branch_name
  description = coalesce(var.description, format("%s - Managed by Terraform", var.branch_name))

}