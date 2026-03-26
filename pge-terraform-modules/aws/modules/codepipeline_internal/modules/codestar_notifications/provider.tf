terraform {
  required_version = ">= 1.1.0"
  required_providers {
    local = {
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}