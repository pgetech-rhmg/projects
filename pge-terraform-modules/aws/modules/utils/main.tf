# providers
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


data "aws_caller_identity" "current" {}

output "utils" {
  value = "Please use one of the available submodules."
}