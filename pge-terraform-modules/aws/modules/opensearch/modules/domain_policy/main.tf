/*
* # AWS Opensearch domain policy module
* Terraform module which creates Domain policy for opensearch
*/
#Filename     : aws/modules/opensearch/modules/domain_policy/main.tf 
#Date         : 04/26/2024
#Author      : PGE
#Description  : Terraform module for creation of Domain policy

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = var.domain_name
  access_policies = var.access_policies
}