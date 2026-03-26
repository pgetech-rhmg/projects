terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.91"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
  }
}