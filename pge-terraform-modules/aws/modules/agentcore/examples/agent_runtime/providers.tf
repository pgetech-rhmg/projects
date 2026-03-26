terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  /* assume_role {
      role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
    } */
}

provider "awscc" {
  region = var.aws_region
  /* assume_role ={
      role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
    } */
}