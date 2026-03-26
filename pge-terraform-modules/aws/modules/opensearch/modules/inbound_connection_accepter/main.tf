/*
 * # AWS Opensearch  module.
 * Terraform module which creates SAF2.0 Opensearch.0 in AWS.
*/
#  Filename    : aws/modules/opensearch/modules/stack/main.tf
#  Date         : 19 Apr 2024
#  Author      : PGE
#  Description : Opensearch inbound connection

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Inbound Connection Accepter
# Description : This terraform module creates a Opensearch.

resource "aws_opensearch_inbound_connection_accepter" "connection_accepter" {
  connection_id = var.connection_id
}