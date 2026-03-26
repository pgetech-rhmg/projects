locals {
  
  environment_config = {
    "990878119577" = { name = "Dev",  branch = "development" }
    "471817339124" = { name = "QA",   branch = "main" }
    "712640766496" = { name = "Prod", branch = "production" }
  }[var.account_num]

  Environment = local.environment_config.name
  tfc_environment = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH != null ? local.environment_config.branch : terraform.workspace
  role_arn = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  
# comply with https://wiki.comp.pge.com/display/CCE/Cloud+Tagging+Standard
  tags = {
    AppID              = "APP-${var.AppID}"
    Environment        = local.Environment
    DataClassification = var.DataClassification
    CRIS               = var.CRIS
    Notify             = var.Notify[0]
    Owner              = var.Owner[0]
    Compliance         = var.Compliance[0]
    Order              = var.Order
  }
}

terraform {
  cloud {
    organization = "pgetech"
    workspaces {
      name = "dev-bfcatest"
    }
  }
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.1.2"
    }
    local = {
      version = "~> 2.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = local.role_arn
  }
}

provider "github" {
  owner = "PGEDigitalCatalyst"
  token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

module "validate-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags = local.tags
}
