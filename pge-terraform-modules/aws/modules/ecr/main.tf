/*
* # AWS Elastic Container Registry module
* Terraform module which creates SAF2.0 ECR in AWS
*/
#
# Filename    : aws/modules/ecr/main.tf
# Date        : 17 february 2021
# Author      : TCS
# Description : Elastic Container Registry module main
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Elastic Container Registry 
# Description : This terraform module creates an Elastic Container Registry(ECR) 

locals {
  namespace       = "ccoe-tf-developers"
  principal_orgid = "o-7vgpdbu22o"
  module_tags     = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}


resource "aws_ecr_repository" "ecr" {
  name = var.ecr_name
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key
  }
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  tags = local.module_tags
}

# Combines the user_defined_policy with the pge_compliance
data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    templatefile("${path.module}/ecr_pge_policy.json", { principal_orgid = local.principal_orgid }),
    var.policy
  ]
}

#adding the repository policy
resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.combined.json
}

#adding lifecycle policy
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count      = var.lifecycle_policy_enable ? 1 : 0
  repository = aws_ecr_repository.ecr.name
  policy     = var.lifecycle_policy
}

#creation of the replication configuration
resource "aws_ecr_replication_configuration" "replication_configuration" {
  count = var.replication_configuration_enable ? 1 : 0
  replication_configuration {
    rule {
      destination {
        region      = var.replication_configuration_region
        registry_id = var.replication_configuration_registry_id
      }
      repository_filter {
        filter      = var.replication_configuration_filter
        filter_type = var.replication_configuration_filter_type
      }
    }
  }
}