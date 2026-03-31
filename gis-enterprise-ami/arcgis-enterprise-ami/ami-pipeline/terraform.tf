terraform {
  required_version = ">= 1.1.0" # terraform://version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }

  default_tags {
    tags = {
      Project     = var.name
      Environment = var.environment
      Component   = "arcgis-enterprise-ami-pipeline"
      ManagedBy   = "terraform"
    }
  }
}
