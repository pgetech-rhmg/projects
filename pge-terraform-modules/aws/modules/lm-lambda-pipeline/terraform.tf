#
#  Filename    : aws/modules/lm-lambda-pipeline/terraform.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "github" {
  owner = "PGEDigitalCatalyst"
  token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
}
