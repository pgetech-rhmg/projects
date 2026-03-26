/*
* # AWS AppSync module
* # Terraform module which creates AppSync domain name api association
*/
# Filename     : aws/modules/appsync/modules/domain_name_api_association/main.tf 
# Date         : 4 October 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of AppSync domain name api association

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appsync_domain_name_api_association" "domain_name_api_association" {
  api_id      = var.api_id
  domain_name = var.domain_name
}