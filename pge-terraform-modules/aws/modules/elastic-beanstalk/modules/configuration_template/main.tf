/*
 * # AWS Elastic Beanstalk configuration template module.
 * Terraform module which creates SAF2.0 aws_elastic_beanstalk_configuration_template in AWS.
*/
#
#  Filename    : aws/modules/elastic-beanstalk/modules/elastic_beanstalk_configuration_template/main.tf
#  Date        : 13 October 2022
#  Author      : TCS
#  Description : Elastic Beanstalk configuration template Creation
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

resource "aws_elastic_beanstalk_configuration_template" "configuration_template" {
  name           = var.template_name
  application    = var.application
  description    = coalesce(var.description, format("%s Elastic Beanstalk - Managed by Terraform", var.template_name))
  environment_id = var.environment_id
  dynamic "setting" {
    #The 'setting' block, can iterate multiple times if multiple values are passed for the variable.
    for_each = var.setting
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }
  solution_stack_name = var.solution_stack_name
}