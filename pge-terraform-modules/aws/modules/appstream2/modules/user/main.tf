/*
 * # AWS AppStream User Module
 * 
 * ✅ WHEN TO USE: For USERPOOL authentication with AppStream-managed users
 */
#  Filename    : aws/modules/appstream2/modules/user/main.tf
#  Date         : 19 Aug 2022
#  Author      : TCS
#  Description : user appstream2.0

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}



resource "aws_appstream_user" "user" {
  authentication_type     = var.authentication_type
  user_name               = var.user_name
  first_name              = var.first_name
  last_name               = var.last_name
  enabled                 = var.enabled_user
  send_email_notification = var.send_email_notification
}