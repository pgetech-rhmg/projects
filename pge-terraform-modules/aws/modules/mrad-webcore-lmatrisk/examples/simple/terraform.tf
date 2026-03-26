terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.5"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = "~> 2"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "tfcr53"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"
    session_name = "webcore-code-terraform"
  }
}

provider "github" {
  token = var.github_token
  owner = "PGEDigitalCatalyst"
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}
