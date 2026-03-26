/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_account_setting_default/main.tf
#  Date        : 13 April 2022
#  Author      : TCS
#  Description : ECS  account setting default resource creation
#

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : ecs module
# Description : This terraform module creates a ecs.

resource "aws_ecs_account_setting_default" "ecs_account_setting_default" {
  name  = var.ecs_account_name
  value = var.ecs_account_setting_value
}