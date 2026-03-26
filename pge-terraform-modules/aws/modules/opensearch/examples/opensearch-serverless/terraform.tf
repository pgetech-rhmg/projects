#
# Filename    : aws/modules/opensearch/examples/opensearch-serverless/terraform.tf
# Date        : 09 Mar 2026
# Author      : PGE
# Description : Terraform configuration for OpenSearch Serverless example

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # The following code is for using cross account assume role
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}
