/*
* # AWS Opensearch package module
* Terraform module which creates package for Opensearch
*/
#Filename     : aws/modules/opensearch/modules/package/main.tf 
#Date         : 18 Apr 2024
#Author      : PGE
#Description  : Terraform module for creation of package

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_opensearch_package" "package" {
  package_name        = var.package_name
  package_description = var.package_description
  package_source {
    s3_bucket_name = var.s3_bucket_name
    s3_key         = var.s3_key
  }
  package_type = var.package_type
}