#  Filename    : aws/modules/opensearch/modules/opensearch-serverless/main.tf
#  Date        : 09 Mar 2026
#  Author      : PGE
#  Description : OpenSearch Serverless Collection with encryption, network, and data access policies

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Description : Default for Tags

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Validate PGE required tags
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#########################################
# OpenSearch Serverless Collection
#########################################

# Module: OpenSearch Serverless Collection Creation
# Description: This terraform module creates an OpenSearch Serverless Collection with security policies
# Resources are created in the following order (controlled by depends_on):
# 1. Encryption Policy (if enabled)
# 2. Network Policy (if enabled)
# 3. Data Access Policy (if enabled)
# 4. Collection (depends on all policies)

# Encryption Policy for the collection
# Must be created before the collection
resource "aws_opensearchserverless_security_policy" "encryption" {
  count = var.create_encryption_policy ? 1 : 0

  name        = var.encryption_policy_name != null ? var.encryption_policy_name : "${var.collection_name}-enc"
  type        = "encryption"
  description = var.encryption_policy_description

  policy = var.use_aws_owned_key ? jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.collection_name}"
        ]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
    }) : jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.collection_name}"
        ]
        ResourceType = "collection"
      }
    ]
    KmsARN = var.kms_key_arn
  })

  lifecycle {
    precondition {
      condition     = var.use_aws_owned_key || (var.kms_key_arn != null && var.kms_key_arn != "")
      error_message = "When use_aws_owned_key is false, a non-empty kms_key_arn must be provided for the OpenSearch Serverless encryption policy."
    }
  }
}

# Network Policy for the collection
# Controls public/VPC access to the collection
# Must be created before the collection
# Note: If vpce_ids are provided, ensure VPC endpoints are created first
#       using depends_on in the calling module
resource "aws_opensearchserverless_security_policy" "network" {
  count = var.create_network_policy ? 1 : 0

  name        = var.network_policy_name != null ? var.network_policy_name : "${var.collection_name}-net"
  type        = "network"
  description = var.network_policy_description

  policy = jsonencode([
    merge(
      {
        Rules = [
          {
            Resource = [
              "collection/${var.collection_name}"
            ]
            ResourceType = "collection"
          },
          {
            Resource = [
              "collection/${var.collection_name}"
            ]
            ResourceType = "dashboard"
          }
        ]
        AllowFromPublic = var.allow_public_access
      },
      length(var.vpce_ids) > 0 ? { SourceVPCEs = var.vpce_ids } : {}
    )
  ])

  # Ensure this policy is created AFTER VPC endpoints are ready
  # The vpce_ids variable should contain VPC endpoint IDs that already exist
  lifecycle {
    precondition {
      condition     = !var.allow_public_access ? length(var.vpce_ids) > 0 : true
      error_message = "When allow_public_access is false, at least one VPC endpoint ID must be provided in vpce_ids to enable private access to the OpenSearch Serverless collection."
    }
  }
}

# Data Access Policy for the collection
# Controls IAM principal permissions for collection and indexes
# Must be created before the collection
# Supports two modes:
#   1. Single-tier: All principals get same access (use_multi_tier_access = false)
#   2. Multi-tier: Separate privileged and public access (use_multi_tier_access = true, matches Amplify pattern)
resource "aws_opensearchserverless_access_policy" "data_access" {
  count = var.create_data_access_policy ? 1 : 0

  name        = var.data_access_policy_name != null ? var.data_access_policy_name : "${var.collection_name}-access"
  type        = "data"
  description = var.data_access_policy_description

  lifecycle {
    precondition {
      condition = var.use_multi_tier_access ? (
        length(var.privileged_principals) > 0 || length(var.public_access_principals) > 0
      ) : length(var.data_access_principals) > 0
      error_message = var.use_multi_tier_access ? "When use_multi_tier_access is true, at least one principal must be provided in privileged_principals or public_access_principals." : "When create_data_access_policy is true, at least one IAM principal must be provided in data_access_principals."
    }
    precondition {
      condition     = !var.use_multi_tier_access || (var.use_multi_tier_access && length(var.public_index_names) > 0 ? length(var.public_access_principals) > 0 : true)
      error_message = "When public_index_names is specified, public_access_principals must also be provided."
    }
  }

  # Single-tier policy (original pattern)
  policy = var.use_multi_tier_access ? jsonencode(
    concat(
      # Rule 1: Collection access for all principals (privileged + public)
      [{
        Rules = [{
          Resource     = ["collection/${var.collection_name}"]
          Permission   = var.data_access_permissions
          ResourceType = "collection"
        }]
        Principal   = distinct(concat(var.privileged_principals, var.public_access_principals))
        Description = "Collection access policy for all roles"
      }],
      # Rule 2: Wildcard index access for privileged principals only
      length(var.privileged_principals) > 0 ? [{
        Rules = [{
          Resource     = ["index/${var.collection_name}/*"]
          Permission   = var.index_permissions
          ResourceType = "index"
        }]
        Principal   = var.privileged_principals
        Description = "Wildcard index access for privileged principals (admins, automation)"
      }] : [],
      # Rule 3: Specific named index access for public principals (if specified)
      length(var.public_index_names) > 0 && length(var.public_access_principals) > 0 ? [{
        Rules = [{
          Resource = [
            for index_name in var.public_index_names : "index/${var.collection_name}/${index_name}"
          ]
          Permission   = var.public_index_permissions
          ResourceType = "index"
        }]
        Principal   = var.public_access_principals
        Description = "Specific named index access for public principals (limited users)"
      }] : []
    )
    ) : jsonencode([
      # Original single-tier policy
      {
        Rules = [
          {
            Resource = [
              "collection/${var.collection_name}"
            ]
            Permission   = var.data_access_permissions
            ResourceType = "collection"
          },
          {
            Resource = [
              "index/${var.collection_name}/*"
            ]
            Permission   = var.index_permissions
            ResourceType = "index"
          }
        ]
        Principal = var.data_access_principals
      }
  ])
}

# OpenSearch Serverless Collection
# The main collection resource that depends on all security policies
resource "aws_opensearchserverless_collection" "collection" {
  name        = var.collection_name
  type        = var.collection_type
  description = var.collection_description

  standby_replicas = var.standby_replicas

  tags = local.module_tags

  timeouts {
    create = var.collection_create_timeout
    delete = var.collection_delete_timeout
  }

  # Explicit dependency order ensures policies are created first
  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.data_access
  ]
}
