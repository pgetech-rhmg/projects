# terraform {
#   required_version = ">= 1.1.0"
# 
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0.0"
#     }
#   }
# }

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.3"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}