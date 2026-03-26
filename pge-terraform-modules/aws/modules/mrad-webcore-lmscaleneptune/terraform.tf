terraform {
  required_version = ">= 1.6"
  cloud {
    hostname     = "app.terraform.io"
    organization = "pgetech"
    workspaces {
      tags = ["app-2586", "webcore"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source                = "integrations/github"
      version               = ">= 4.0"
      configuration_aliases = [github]
    }
    archive = {
      version = "~> 2.0"
      source  = "hashicorp/archive"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
    sumologic = {
      version               = "~> 2.6"
      source                = "SumoLogic/sumologic"
      configuration_aliases = [sumologic]
    }
  }
}
