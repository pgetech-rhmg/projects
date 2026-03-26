terraform {
  required_version = ">= 1.1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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

provider "github" {
  token = local.github_token
  owner = local.owner
}

locals {
  owner               = regex("https:\\/\\/github.com\\/(\\w+)\\/([\\w-_]+)(.git$|$)", var.github_repo_url)[0]
  github_sm_list      = split(":", var.secretsmanager_github_token_secret_name)
  github_sm_name      = local.github_sm_list[0]
  github_sm_key_name  = length(local.github_sm_list) == 2 ? local.github_sm_list[1] : null
  github_sm_key_value = local.github_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.github_token_id.secret_string)[local.github_sm_key_name] : null
  github_token        = local.github_sm_key_value != null ? local.github_sm_key_value : data.aws_secretsmanager_secret_version.github_token_id.secret_string
}

data "aws_secretsmanager_secret" "github_token" {
  name = local.github_sm_name
}

data "aws_secretsmanager_secret_version" "github_token_id" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}
