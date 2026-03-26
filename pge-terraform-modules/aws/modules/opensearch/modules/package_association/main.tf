
#Date         : 18 Apr 2024
#Author       : PGE
#Description  : Terraform module for creation of aws_opensearch_package_association

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_opensearch_package_association" "package_association" {
  package_id  = var.package_id
  domain_name = var.domain_name
}