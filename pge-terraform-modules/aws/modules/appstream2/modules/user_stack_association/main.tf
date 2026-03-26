/*
* # AWS AppStream User Stack Association Module
* 
* ✅ WHEN TO USE: For USERPOOL authentication with manual user-stack associations
*/
#Filename     : aws/modules/appstream2/modules/user_stack_association/main.tf 
#Date         : 18 Aug 2022
#Author       : TCS
#Description  : Terraform module for creation of user_stack_association

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appstream_user_stack_association" "user_stack" {
  authentication_type     = var.authentication_type
  stack_name              = var.stack_name
  user_name               = var.user_name
  send_email_notification = var.send_email_notification
}