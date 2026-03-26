terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [
        aws.default,
        aws.r53
      ]
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
      version = "~> 2.6"
      source  = "SumoLogic/sumologic"
    }
  }
}
