/*
* # AWS AppSync module
* # Terraform module which creates AppSync domain_name
*/
# Filename     : aws/modules/appsync/modules/domain_name/main.tf 
# Date         : 4 October 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of AppSync domain_name

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appsync_domain_name" "domain_name" {
  certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
  description     = coalesce(var.description, format("%s appsync domain_name", var.domain_name))
}