
#  Filename    : aws/modules/opensearch/modules/outbound_connection/main.tf
#  Date         : 18 Apr 2024
#  Author      : PGE
#  Description : outbound_connection Opensearch

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Outbound Connection
# Description : This terraform module creates a Opensearch outbound connection

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_opensearch_outbound_connection" "outbound_connection" {
  connection_alias = var.connection_alias #"outbound_connection"
  connection_mode  = var.connection_mode
  local_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = var.local_domain
  }

  remote_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = var.remote_domain
  }
}