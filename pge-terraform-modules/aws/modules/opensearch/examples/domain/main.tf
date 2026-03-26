/*
* # AWS Opensearch with usage example
* Terraform module which creates Opensearch Domain and other resources in AWS. 
*/
#
# Filename    : modules/opensearch/examples/opensearch/main.tf
# Author      : PGE
# Description : The Terraform usage example creates aws opensearch resources


locals {
  optional_tags = var.optional_tags
  Order         = var.Order
  # name          = "${var.name}-${random_string.name.result}"
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

################################################################################
# Supporting Resources
################################################################################
#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length           = 8
  upper            = false
  special          = true
  override_special = "_-"
}

module "domain" {
  source = "../../"

  domain_name                     = var.domain_name
  engine_version                  = var.engine_version
  cluster_config                  = var.cluster_config
  vpc_options                     = var.vpc_options
  advanced_options                = var.advanced_options
  advanced_security_options       = var.advanced_security_options
  encrypt_at_rest_options         = var.encrypt_at_rest_options
  domain_endpoint_options         = var.domain_endpoint_options
  node_to_node_encryption_options = var.node_to_node_encryption_options
  ebs_options                     = var.ebs_options
  log_publishing_options          = var.log_publishing_options
  tags                            = merge(module.tags.tags, local.optional_tags)
}


module "vpc_endpoint" {
  source = "../../modules/vpc_endpoint"

  domain_arn         = module.domain.domain_arn
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
}