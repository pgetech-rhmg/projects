terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
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

# OpenSearch provider for index management
# Uses AWS authentication to connect to OpenSearch Serverless
# When using AWS SSO, the provider automatically inherits credentials
# from the AWS provider configuration
provider "opensearch" {
  url         = module.opensearch_serverless.collection_endpoint
  healthcheck = false

  aws_region = var.aws_region

  aws_assume_role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"

  # Use AWS signature v4 for OpenSearch Serverless
  aws_signature_service = "aoss"
}