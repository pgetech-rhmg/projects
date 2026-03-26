terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws, aws.r53, aws.us_east_1]
    }
    github = {
      source                = "integrations/github"
      version               = "~> 5.0"
      configuration_aliases = [github]
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

locals {
  owner               = regex("https:\\/\\/github.com\\/(\\w+)\\/([\\w-_]+)(.git$|$)", var.github_repo_url)[0]
  github_sm_list      = split(":", var.secretsmanager_github_token)
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