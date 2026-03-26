##################################################################
#
#  Filename    : aws/modules/lm-pipeline/terraform.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
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
