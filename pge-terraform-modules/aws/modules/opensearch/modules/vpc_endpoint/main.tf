/*
* # AWS Opensearch vpc_endpoint module
* Terraform module which creates vpc endpoint for the Domain
*/
#Filename     : aws/modules/opensearch/modules/vpc_endpoint/main.tf 
#Date         : 18 Apr 2024
#Author      : PGE
#Description  : Terraform module for creation of vpc_endpoint

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_opensearch_vpc_endpoint" "vpc_endpoint" {
  domain_arn = var.domain_arn
  vpc_options {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}