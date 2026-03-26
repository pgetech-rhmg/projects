terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}


# The provider block should include logic to determine whether to use the Identity Center profile 
# (for local runs) or default credentials (for Terraform Cloud).
# The dynamic provider block is used to allow the module to be used in both TFC and non-TFC environments
provider "aws" {
  region  = var.aws_region
  profile = local.is_tfc ? null : "default" # Use Identity Center profile for local runs, null for TFC
  dynamic "assume_role" {
    for_each = local.is_tfc ? [1] : []
    content {
      role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
    }
  }
}

# Route 53 provider with alias - handles DNS zone management
# Uses Identity Center profile 'r53' for local runs or assume role for Terraform Cloud
provider "aws" {
  alias   = "r53"
  region  = var.aws_r53_region
  profile = local.is_tfc ? null : "r53" # Use Identity Center profile for local runs, null for TFC
  dynamic "assume_role" {
    for_each = local.is_tfc ? [1] : []
    content {
      role_arn = "arn:aws:iam::${local.r53_account_num}:role/${local.r53_aws_role}"
    }
  }
}

# US East 1 provider with alias - required for CloudFront and ACM certificates
# Uses Identity Center profile 'default' for local runs or assume role for Terraform Cloud
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = local.is_tfc ? null : "default" # Use Identity Center profile for local runs, null for TFC
  dynamic "assume_role" {
    for_each = local.is_tfc ? [1] : []
    content {
      role_arn = "arn:aws:iam::${local.d_account_id}:role/${local.d_role}"
    }
  }
}

provider "github" {
  token = local.github_token
  owner = local.owner
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



